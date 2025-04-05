{ config, pkgs, lib, ... }:

let
  ollamaDataDir = "/home/david/ollama-data";
  ollamaCmd = pkgs.writeShellScript "ollama-run" ''
    # Clean up any existing container
    ${pkgs.podman}/bin/podman rm -f ollama 2>/dev/null || true
    
    # Run with CDI support
    export NVIDIA_DISABLE_REQUIRE=1
    exec ${pkgs.podman}/bin/podman run \
      --name ollama \
      --replace \
      -p 11434:11434 \
      -v ${ollamaDataDir}:/root/.ollama:Z \
      --device=nvidia.com/gpu=all \
      --security-opt=label=disable \
      --health-cmd="curl -f http://localhost:11434 || exit 1" \
      --health-interval=30s \
      --health-start-period=30s \
      ollama/ollama:latest
  '';
in {
  environment.systemPackages = with pkgs; [
    ollama
    podman
    curl
    nvidia-container-toolkit
  ];

  # CDI configuration
  hardware.nvidia-container-toolkit.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  boot.kernel.sysctl = {
    "user.max_user_namespaces" = 28633;
  };

  systemd.tmpfiles.rules = [
    "d ${ollamaDataDir} 0755 david users - -"
  ];

  systemd.user.services.ollama = {
    description = "Ollama rootless container";
    wantedBy = [ "default.target" ];
    after = [ "network.target" ];
    
    serviceConfig = {
      ExecStart = ollamaCmd;
      ExecStop = "${pkgs.podman}/bin/podman stop -t 10 ollama";
      ExecStopPost = "${pkgs.podman}/bin/podman rm -f ollama";
      Type = "simple";
      TimeoutStartSec = "10min";
      Restart = "on-failure";
      RestartSec = "30s";
      Environment = [
        "NVIDIA_VISIBLE_DEVICES=all"
        "NVIDIA_DRIVER_CAPABILITIES=compute,utility"
      ];
    };

    environment = {
      XDG_RUNTIME_DIR = "/run/user/%U";
      OLLAMA_HOST = "0.0.0.0:11434";
    };
  };

  services.logind.extraConfig = ''
    RuntimeDirectorySize=8G
    RemoveIPC=no
  '';
}

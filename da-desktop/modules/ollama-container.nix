{ config, pkgs, lib, ... }:

let
  ollamaDataDir = "/home/david/ollama-data";
  ollamaCmd = pkgs.writeShellScript "ollama-run" ''
    ${pkgs.podman}/bin/podman run \
      --name ollama \
      --replace \
      -p 11434:11434 \
      -v ${ollamaDataDir}:/root/.ollama:Z \
      --security-opt=label=disable \
      --gpus=all \
      ollama/ollama:latest
  '';
in {
  environment.systemPackages = with pkgs; [
    ollama
    podman
  ];

  hardware.nvidia-container-toolkit.enable = true;
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;
  
  boot.kernel.sysctl = {
    "user.max_user_namespaces" = 28633;
  };

  systemd.tmpfiles.rules = [
    "d ${ollamaDataDir} 0755 david users - -"
  ];

  systemd.user.services.ollama = {
    description = "Ollama rootless container";
    wantedBy = [ "default.target" ];
    after = [ "network.target" "podman.service" ];
    requires = [ "podman.service" ];
    
    serviceConfig = {
      ExecStartPre = "${pkgs.podman}/bin/podman pull ollama/ollama:latest";
      ExecStart = ollamaCmd;
      ExecStop = "${pkgs.podman}/bin/podman stop -t 10 ollama";
      ExecStopPost = "${pkgs.podman}/bin/podman rm -f ollama";
      Type = "notify";
      NotifyAccess = "all";
      TimeoutStopSec = 30;
    };

    environment = {
      XDG_RUNTIME_DIR = "/run/user/%U";
    };
  };

  services.logind.extraConfig = ''
    RuntimeDirectorySize=8G
    RemoveIPC=no
  '';
}

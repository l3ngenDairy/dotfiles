{ config, pkgs, lib, ... }:

let
  ollamaDataDir = "/home/david/ollama-data";
  ollamaCmd = pkgs.writeShellScript "ollama-run" ''
    # Clean up any existing container first
    ${pkgs.podman}/bin/podman rm -f ollama 2>/dev/null || true
    
    # Run with health checks and GPU support
    exec ${pkgs.podman}/bin/podman run \
      --name ollama \
      --replace \
      -p 11434:11434 \
      -v ${ollamaDataDir}:/root/.ollama:Z \
      --security-opt=label=disable \
      --gpus=all \
      --health-cmd="curl -f http://localhost:11434 || exit 1" \
      --health-interval=30s \
      --health-start-period=30s \
      --health-retries=3 \
      ollama/ollama:latest
  '';
in {
  environment.systemPackages = with pkgs; [
    ollama
    podman
    curl
    nvidia-podman
  ];

  # GPU and container configuration
  hardware.nvidia-container-toolkit.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    extraPackages = [ pkgs.nvidia-podman ];
  };
  
  # Required for rootless containers
  boot.kernel.sysctl = {
    "user.max_user_namespaces" = 28633;
  };

  # Ensure data directory exists
  systemd.tmpfiles.rules = [
    "d ${ollamaDataDir} 0755 david users - -"
  ];

  # User service definition
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
      
      # Critical changes:
      Type = "simple";  # Changed from 'exec' as Ollama doesn't fork
      TimeoutStartSec = "10min";  # Increased timeout
      TimeoutStopSec = "5min";
      Restart = "always";  # More aggressive restart policy
      RestartSec = "30s";
      
      # Resource limits (adjust based on your system)
      MemoryHigh = "8G";
      MemoryMax = "10G";
    };

    environment = {
      XDG_RUNTIME_DIR = "/run/user/%U";
      OLLAMA_HOST = "0.0.0.0:11434";
      OLLAMA_DEBUG = "1";  # Enable debug logging
    };
  };

  # Enable lingering for user services
  services.logind.extraConfig = ''
    RuntimeDirectorySize=8G
    RemoveIPC=no
  '';

  # Optional: Add NVIDIA-specific environment variables
  environment.sessionVariables = {
    NVIDIA_DRIVER_CAPABILITIES = "compute,utility";
    NVIDIA_VISIBLE_DEVICES = "all";
  };
}

{ config, pkgs, lib, ... }:

let
  ollamaDataDir = "/home/david/ollama-data";
in {
  environment.systemPackages = with pkgs; [
    ollama
    podman
  ];

  # Enable GPU support for rootless containers
  hardware.nvidia-container-toolkit.enable = true;
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;
  
  # Required for rootless GPU access
  boot.kernel.sysctl = {
    "user.max_user_namespaces" = 28633;
  };

  # Configure cgroups v2 for rootless containers
  systemd.enableUnifiedCgroupHierarchy = true;

  # Ensure ollama data directory exists with correct permissions
  systemd.tmpfiles.rules = [
    "d ${ollamaDataDir} 0755 david users - -"
  ];

  # Create a user systemd service for rootless container
  systemd.user.services.ollama = {
    description = "Ollama rootless container";
    wantedBy = [ "default.target" ];
    after = [ "network.target" "podman.service" ];
    requires = [ "podman.service" ];
    
    serviceConfig = {
      ExecStartPre = "${pkgs.podman}/bin/podman pull ollama/ollama:latest";
      ExecStart = "${pkgs.podman}/bin/podman run --name ollama \
        --replace \
        -p 11434:11434 \
        -v ${ollamaDataDir}:/root/.ollama:Z \
        --security-opt=label=disable \
        --gpus=all \
        ollama/ollama:latest";
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

  # Allow user services to persist after logout
  systemd.linger.enable = true;
  users.users.david.linger = true;
}

{ config, pkgs, lib, ... }:

let
  ollamaDataDir = "/home/david/ollama-data";
in {
  # Add ollama to system packages
  environment.systemPackages = with pkgs; [
    ollama
    podman  # Ensure podman is available
  ];
        
  # Enable GPU support for rootless containers
  hardware.nvidia-container-toolkit.enable = true;
  virtualisation.podman.enableNvidia = true;

  # Podman configuration for rootless containers
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;  # Create 'docker' alias for podman
  };

  # Ensure ollama data directory exists
  systemd.tmpfiles.rules = [
    "d ${ollamaDataDir} 0755 david users - -"
  ];

  # Create a user service for the Ollama container
  systemd.user.services.ollama = {
    description = "Ollama Container Service";
    wantedBy = [ "default.target" ];
    after = [ "network.target" "podman.socket" ];
    requires = [ "podman.socket" ];

    serviceConfig = {
      ExecStart = "${pkgs.podman}/bin/podman run \
        --name ollama \
        -p 11434:11434 \
        -v ${ollamaDataDir}:/root/.ollama:Z \
        --security-opt=label=disable \
        --gpus=all \
        ollama/ollama:latest";
      ExecStop = "${pkgs.podman}/bin/podman stop ollama";
      ExecStopPost = "${pkgs.podman}/bin/podman rm ollama";
      Restart = "on-failure";
      TimeoutStartSec = "infinity";                 
    };

    environment = {
      XDG_RUNTIME_DIR = "/run/user/${toString config.users.users.david.uid}";
      DOCKER_HOST = "unix:///run/user/${toString config.users.users.david.uid}/podman/podman.sock";
    };
  };

  # Enable lingering so the service starts at boot
  users.users.david.linger = true;
}

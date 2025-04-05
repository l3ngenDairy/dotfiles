{ config, pkgs, lib, ... }:

let
  ollamaDataDir = "/home/david/ollama-data";
in {
  environment.systemPackages = with pkgs; [
    ollama
  ];

  # Enable GPU container support (required for nvidia-smi to work inside)
  hardware.nvidia-container-toolkit.enable = true;

  # Ensure ollama data directory exists on boot
  systemd.tmpfiles.rules = [
    "d ${ollamaDataDir} 0755 david users - -"
  ];

  # Define the Ollama container with GPU support in a rootless manner
  virtualisation.oci-containers.containers.ollama = {
    image = "ollama/ollama:latest";
    ports = [ "11434:11434" ];
    volumes = [ "${ollamaDataDir}:/root/.ollama:Z" ]; # Use :Z for SELinux compatibility
    extraOptions = [ "--gpus=all" ];

    # Rootless Docker configuration
    user = "david"; # Set the user for the container
    security.opt = "no-new-privileges"; # Optional: security setting to avoid privilege escalation

    # Set Docker socket for rootless mode (assumes rootless Docker is set up)
    environment = {
      DOCKER_HOST = "unix:///run/user/${config.users.users.david.uid}/docker.sock";
    };
  };
}


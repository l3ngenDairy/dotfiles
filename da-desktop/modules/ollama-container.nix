{ config, pkgs, lib, ... }:

let
  ollamaDataDir = "/home/david/ollama-data";
  # Check if the 'david' user exists and fetch the UID
  userUid = if config.users.users.david != null && config.users.users.david.uid != null then
    config.users.users.david.uid
  else
    throw "User 'david' UID not found";
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

    # Ensure DOCKER_HOST is correctly set for rootless Docker
    environment.variables = {
      DOCKER_HOST = "unix:///run/user/${userUid}/docker.sock";
    };
  };
}


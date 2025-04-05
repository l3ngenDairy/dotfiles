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
    user = "david";
    group = "users";
    security.opt = "no-new-privileges";
    environment = {
      DOCKER_HOST = "unix:///run/user/${config.users.users.david.uid}/docker.sock";
    };
  };
}


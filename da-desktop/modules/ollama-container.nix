{ config, pkgs, lib, ... }:

let
  ollamaDataDir = "/home/david/ollama-data";
in {
  # Enable GPU container support (required for nvidia-smi to work inside)
  hardware.nvidia-container-toolkit.enable = true;

  # Ensure ollama data directory exists on boot
  systemd.tmpfiles.rules = [
    "d ${ollamaDataDir} 0755 david users - -"
  ];

  # Define the Ollama container with GPU support
  virtualisation.oci-containers.containers.ollama = {
    image = "ollama/ollama:latest";
    ports = [ "11434:11434" ];
    volumes = [ "${ollamaDataDir}:/root/.ollama:Z" ]; # Use :Z for SELinux compatibility
    extraOptions = [ "--gpus=all" ];
  };
}


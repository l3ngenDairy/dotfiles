{ config, pkgs, lib, ... }:

let
  ollamaDataDir = "/home/david/ollama-data";
in {
  # Ensure the directory exists
  systemd.tmpfiles.rules = [
    "d ${ollamaDataDir} 0755 david users - -"
  ];

  virtualisation.oci-containers.containers.ollama = {
    image = "ollama/ollama:latest";
    ports = [ "11434:11434" ];
    volumes = [ "${ollamaDataDir}:/root/.ollama" ];
    extraOptions = [ "--gpus=all" ];
  };

  # Optional: Ensure Docker is enabled
  virtualisation.docker.enable = true;
  users.users.david.extraGroups = [ "docker" ];
}


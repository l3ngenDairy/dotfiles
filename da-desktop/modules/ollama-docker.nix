{ config, pkgs, lib, ... }:
{
  # Configure rootless Docker with NVIDIA support
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
    package = pkgs.docker-rootless-extras.override {
      inherit (config.hardware.nvidia) package;
    };
  };

  # Ollama container definition
  virtualisation.oci-containers.containers.ollama = {
    image = "ollama/ollama";
    autoStart = true;
    volumes = [ "ollama:/root/.ollama" ];
    ports = [ "11434:11434" ];
    environment = {
      NVIDIA_VISIBLE_DEVICES = "all";
    };
    extraOptions = [
      "--gpus=all"
      "--runtime=nvidia"
    ];
  };

  # Ensure the ollama volume is created
  systemd.tmpfiles.rules = [
    "v /var/lib/docker/volumes/ollama 0755 david docker -"
  ];
}

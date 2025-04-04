{ config, pkgs, lib, ... }:

{
  # Merge with your existing Docker configuration
  virtualisation.docker = {
    enableNvidia = true;  # Enable NVIDIA container support
    daemon.settings = {
      "runtimes" = {
        "nvidia" = {
          "path" = "${pkgs.nvidia-docker}/bin/nvidia-container-runtime";
          "runtimeArgs" = [];
        };
      };
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
}

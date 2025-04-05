{ config, pkgs, lib, ... }:

let
  ollamaDataDir = "/home/david/ollama-data";
in {
  environment.systemPackages = with pkgs; [
    ollama
    docker-compose
  ];

  # Enable rootless Podman containers
  virtualisation = {
    containers.enable = true;
    containers.storage.settings = {
      storage = {
        driver = "overlay";
        runroot = "/run/containers/storage";
        graphroot = "/var/lib/containers/storage";
        rootless_storage_path = "/tmp/containers-$USER";
        options.overlay.mountopt = "nodev,metacopy=on";
      };
    };

    oci-containers.backend = "podman";
    podman = {
      enable = true;
      enableNvidia = true;  # Enable Nvidia support for Podman
      dockerCompat = true;  # Enable Docker compatibility
    };
  };

  # Enable GPU container support (required for nvidia-smi to work inside)
  hardware.nvidia-container-toolkit.enable = true;

  # Ensure ollama data directory exists on boot
  systemd.tmpfiles.rules = [
    "d ${ollamaDataDir} 0755 david users - -"
  ];

  # Define the Ollama container with GPU support (rootless with Podman)
  virtualisation.oci-containers.containers.ollama = {
    image = "ollama/ollama:latest";
    ports = [ "11434:11434" ];
    volumes = [ "${ollamaDataDir}:/root/.ollama:Z" ];  # Use :Z for SELinux compatibility
    extraOptions = [ "--gpus=all" ];  # GPU support for rootless
  };

  # Initialize Docker host for Podman if not already set
  environment.extraInit = ''
    if [ -z "$DOCKER_HOST" -a -n "$XDG_RUNTIME_DIR" ]; then
      export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
    fi
  '';
}


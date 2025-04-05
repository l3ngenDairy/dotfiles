{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;  # optional, makes `docker` CLI work
    enableNvidia = true;  # GPU support
  };

  hardware.nvidia-container-toolkit.enable = true;
}


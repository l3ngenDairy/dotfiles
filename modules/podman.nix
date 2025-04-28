{ pkgs, ... }: {
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # Optional: enables `docker` CLI
  };

  environment.systemPackages = with pkgs; [
    ollama # Optional: CLI client for local use
  ];

  # Enables GPU passthrough for containers
  hardware.nvidia-container-toolkit.enable = true;
}


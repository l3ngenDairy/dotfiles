{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;  # optional, makes `docker` CLI work
    enableNvidia = true;  # GPU support
  };
  environment.systemPackages = with pkgs; [
    ollama           
  ];
  
  hardware.nvidia-container-toolkit.enable = true;
}


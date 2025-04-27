{ config, pkgs, lib, ... }:

{ 

        
  environment.systemPackages = with pkgs; [
     nvidia-docker
     nvidia-container-toolkit
  ];
  # Enable NVIDIA graphics drivers
  hardware.graphics.enable = true;

  # Specify NVIDIA as the video driver for X server
  services.xserver.videoDrivers = [ "nvidia" ];

  # NVIDIA-specific configuration
  hardware.nvidia = {
    # Enable modesetting for better compatibility
     modesetting.enable = true;
     open = false;
     powerManagement.enable = false;           


    # Enable the NVIDIA settings application
     nvidiaSettings = true;

    # Use the stable version of the NVIDIA driver package
     package = config.boot.kernelPackages.nvidiaPackages.latest;
     };
  hardware.nvidia-container-toolkit.enable = true;    
}

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/all.nix
      ../user.nix
    ];
  # Install firefox.
  programs.firefox.enable = true;
  custom.webcam.enable = true; 


        #added to get fitgirl to install not sure if needed      
  swapDevices = [
    {
      device = "/swapfile";
      size = 4096; # Size in MB (4GB)
    }
  ];
  boot.kernel.sysctl = {
    "vm.overcommit_memory" = 1;
    "vm.max_map_count" = 1048576;
  };

  

  services.fwupd.enable = true;

  

        #single gpu passthrough attempt
        # services.single-gpu-passthrough.enable = true;
        #  boot.kernelParams = [ 
        #    "amd_iommu=on"
        #   "iommu=pt" 
        #  ];     
        #  boot.kernelModules = [ "vfio_pci" "vfio" "vfio_iommu_type1" "vfio_virqfd" ];      
          

  hardware.enableAllFirmware = true;
  system.stateVersion = "24.11";
  networking.hostName = "da-desktop";
}

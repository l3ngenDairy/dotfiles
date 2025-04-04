{ pkgs, config, ... }:
{
 
virtualisation.docker = {
    enable = true;
                # enableNvidia = true;
  };

  users.users.david = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

hardware.nvidia-container-toolkit.enable;       
}


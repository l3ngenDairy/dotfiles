{ config, pkgs, ... }: {
  services.upower.enable = lib.mkForce false;
        
}


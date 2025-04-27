{ config, pkgs, lib, ... }: {
  services.upower.enable = lib.mkForce false;
        
}


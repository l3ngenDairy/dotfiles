{ config, pkgs, ... }:

{
  # Enable ratbagd (libratbag) service and ensure the package is available
  services.ratbagd = {
    enable = true;
    package = pkgs.libratbag;  # Explicitly specify the package
  };
  environment.systemPackages = with pkgs; [
    libratbag
    piper            
  ];
  
  # Apply your custom configuration via a systemd service
  systemd.user.services.logitech-g502-config = {
    description = "Configure Logitech G502 HERO Mouse";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "logitech-g502-config" ''
        # Wait for ratbagd to be ready
        sleep 2

        # Set polling rate
        ${pkgs.libratbag}/bin/ratbagctl "Logitech G502 HERO Gaming Mouse" profile 0 rate set 1000

        # Set DPI to 2400 and make it active
        ${pkgs.libratbag}/bin/ratbagctl "Logitech G502 HERO Gaming Mouse" profile 0 resolution 1 set 2400
        ${pkgs.libratbag}/bin/ratbagctl "Logitech G502 HERO Gaming Mouse" profile 0 resolution set 1

        # Disable other resolutions
        ${pkgs.libratbag}/bin/ratbagctl "Logitech G502 HERO Gaming Mouse" profile 0 resolution disable 0
        ${pkgs.libratbag}/bin/ratbagctl "Logitech G502 HERO Gaming Mouse" profile 0 resolution disable 2
        ${pkgs.libratbag}/bin/ratbagctl "Logitech G502 HERO Gaming Mouse" profile 0 resolution disable 3
        ${pkgs.libratbag}/bin/ratbagctl "Logitech G502 HERO Gaming Mouse" profile 0 resolution disable 4

        # Rebind DPI buttons
        ${pkgs.libratbag}/bin/ratbagctl "Logitech G502 HERO Gaming Mouse" profile 0 button 5 action button 6
        ${pkgs.libratbag}/bin/ratbagctl "Logitech G502 HERO Gaming Mouse" profile 0 button 6 action button 7
        ${pkgs.libratbag}/bin/ratbagctl "Logitech G502 HERO Gaming Mouse" profile 0 button 7 action button 8

        # Turn off LEDs
        ${pkgs.libratbag}/bin/ratbagctl "Logitech G502 HERO Gaming Mouse" profile 0 led 0 set mode off
        ${pkgs.libratbag}/bin/ratbagctl "Logitech G502 HERO Gaming Mouse" profile 0 led 1 set mode off
      '';
    };
  };
}

#{ pkgs ,config , ... }:{
#  services.ratbagd.enable = true; 
#        
#  environment.systemPackages = with pkgs; [
#    libratbag
        #   piper            
        # ];
#}c



{ config, pkgs, ... }:

{
  services.ratbagd = {
    enable = true;
    package = pkgs.libratbag;
  };

  systemd.user.services.logitech-g502-config = {
    description = "Configure Logitech G502 HERO Mouse";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "logitech-g502-config" ''
        # Wait for ratbagd to be ready
        sleep 5

        DEVICE="singing-gundi"

        # Button remapping - correct syntax
        # Buttons are numbered starting from 1 in the action command
        ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 button 5 set button6
        ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 button 6 set button7
        ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 button 7 set button8

        # Alternative method if above doesn't work:
        # ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 button 5 set key KEY_6
        # ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 button 6 set key KEY_7
        # ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 button 7 set key KEY_8
      '';
    };
  };
}

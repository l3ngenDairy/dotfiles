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

        # First reset to default
        ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 reset

        # Button remapping - using the correct syntax
        ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 button 5 action set button button6
        ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 button 6 action set button button7
        ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 button 7 action set button button8

        # Ensure profile 0 is active (your output shows profile 1 is active)
        ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 set-active
      '';
    };
  };
}

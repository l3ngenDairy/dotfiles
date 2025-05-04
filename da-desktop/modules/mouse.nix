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

        # First reset the profile to ensure clean state
        ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 reset

        # Button remapping using the correct action syntax
        ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 button 5 action set button 6
        ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 button 6 action set button 7
        ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 button 7 action set button 8

        # Alternative method using special actions if above doesn't work
        # ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 button 5 action set special doubleclick
        # ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 button 6 action set special forward
        # ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 button 7 action set special back

        # Make sure profile 0 is active
        ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 set-active
      '';
    };
  };
}

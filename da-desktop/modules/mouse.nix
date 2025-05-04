{ config, pkgs, ... }:

{
  services.ratbagd.enable = true;
  environment.systemPackages = with pkgs; [ libratbag piper ];

  # Proper user service with automatic restart
  systemd.user.services.logitech-g502-config = {
    description = "Configure Logitech G502 HERO Mouse";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" "ratbagd.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "logitech-g502-config" ''
        # Wait for device (with timeout)
        for i in {1..10}; do
          if ${pkgs.libratbag}/bin/ratbagctl list | grep -q "singing-gundi"; then
            break
          fi
          sleep 1
        done

        # Apply settings
        ${pkgs.libratbag}/bin/ratbagctl "singing-gundi" profile 0 resolution 0 dpi set 1900
        ${pkgs.libratbag}/bin/ratbagctl "singing-gundi" profile 0 resolution active set 0
        ${pkgs.libratbag}/bin/ratbagctl "singing-gundi" profile 0 button 5 action set button 6
        ${pkgs.libratbag}/bin/ratbagctl "singing-gundi" profile 0 button 6 action set button 7
        ${pkgs.libratbag}/bin/ratbagctl "singing-gundi" profile 0 button 7 action set button 8
      '';
      RestartSec = 5;
      X-RestartIfChanged = true;
    };

    # Automatically restart when the mouse is plugged in
    unitConfig = {
      StartLimitIntervalSec = 0;
      RefuseManualStart = false;
    };
  };

  # Add udev rule to trigger service when mouse is connected
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c08b", TAG+="systemd", ENV{SYSTEMD_USER_WANTS}+="logitech-g502-config.service"
  '';
}

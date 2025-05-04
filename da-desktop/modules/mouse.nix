{ config, pkgs, ... }:

{
  # Enable ratbagd with the correct package
  services.ratbagd = {
    enable = true;
    package = pkgs.libratbag;
  };

  environment.systemPackages = with pkgs; [
    libratbag
    piper
  ];

  # Systemd service to configure the mouse
  systemd.user.services.logitech-g502-config = {
    description = "Configure Logitech G502 HERO Mouse";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "logitech-g502-config" ''
        # Wait for ratbagd to be ready
        sleep 5  # Increased delay for more reliability

        # Use the actual device name from ratbagctl list
        DEVICE="singing-gundi"

        # First reset to default to ensure clean state
        ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 reset

        # Set polling rate
        ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 rate set 1000

        # Configure DPI settings
        ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 resolution 1 set 2400
        ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 resolution set 1
        ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 resolution disable 0
        ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 resolution disable 2
        ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 resolution disable 3
        ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 resolution disable 4

        # Rebind buttons (using correct button numbers from your info output)
        ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 button 5 action button button6
        ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 button 6 action button button7
        ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 button 7 action button button8

        # Disable all other profiles
        for profile in 1 2 3 4; do
          ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile $profile disable
        done

        # Turn off LEDs
        ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 led 0 set mode off
        ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 led 1 set mode off

        # Make profile 0 active (in case another profile was active)
        ${pkgs.libratbag}/bin/ratbagctl "$DEVICE" profile 0 set-active
      '';
    };
  };
}

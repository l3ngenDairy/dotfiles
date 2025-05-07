{ config, lib, pkgs, ... }:

let
  solaarCmd = "${pkgs.solaar}/bin/solaar ";
in
{
  options.solaar-autostart.enable = lib.mkEnableOption "Enable Solaar auto-start for a specific user";

  config = lib.mkIf config.solaar-autostart.enable {
    environment.systemPackages = [ pkgs.solaar ];

    systemd.services.solaar = {
      description = "Solaar Daemon";
      after = [ "graphical-session.target" ];
      wantedBy = [ "multi-user.target" ];  # Ensure it's available for multi-user targets (graphical + multi-user)

      serviceConfig = {
        ExecStart = solaarCmd;
        Restart = "on-failure";
        User = "root";  # Run as root for elevated privileges
        Group = "root";  # Run as root for elevated privileges
        # Combine all environment variables in one entry
        Environment = "DISPLAY=:0"  # Set DISPLAY for graphical session
                       + " XAUTHORITY=%h/.Xauthority"  # Ensure access to X session
                       + " DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus";  # Adjust with your user ID if necessary
      };
    };
  };
}


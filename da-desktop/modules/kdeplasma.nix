{ config, pkgs, ... }:
{
  # Enable the X server (needed for graphical desktop environments)
  services.xserver.enable = true;

  # Enable the SDDM login manager (used to graphically log into KDE Plasma)
  services.displayManager.sddm.enable = true;

  # Enable KDE Plasma 6 desktop environment
  services.desktopManager.plasma6.enable = true;

  # Enable automatic login without needing to enter password
  services.displayManager.autoLogin.enable = true;
  
  # Set the user that will be automatically logged in
  services.displayManager.autoLogin.user = "david";

  # --- Performance Tweaks ---

  # Mount all disks with 'noatime' to reduce SSD writes (no update of access time on file reads)
  fileSystems."/".options = [ "noatime" ];
  
  # Enable systemd timer to periodically TRIM the SSD
  services.fstrim.enable = true;
services.desktopManager.plasma6.startWithEmptySession = true;

   # Plasma 6 Specific: Exclude some heavy default packages if you want a lighter Plasma
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konqueror     # Heavy old browser
    khelpcenter   # Not needed usually
    plasma-sdk    # Developer tools, not needed for normal users
  ];
}


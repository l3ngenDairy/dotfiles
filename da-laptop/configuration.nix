{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/all.nix
      ../user.nix



    ];
  # Install firefox.
  programs.firefox.enable = true;

  hardware.enableAllFirmware = true;
  system.stateVersion = "24.11"; # Did you read the comment?
  networking.hostName = "da-desktop";
}

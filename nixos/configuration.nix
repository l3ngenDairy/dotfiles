# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      ./modules/all.nix

    ];
  # Install firefox.
  programs.firefox.enable = true;

  hardware.enableAllFirmware = true;
  system.stateVersion = "24.11"; # Did you read the comment?
}

{ config, pkgs, ... }: {
  home.username = "david";
  home.homeDirectory = "/home/david";

  programs.git.enable = true;

  home.packages = with pkgs; [
    neovim
    htop
    curl
  ];

  home.stateVersion = "23.11"; # or your current NixOS version
}


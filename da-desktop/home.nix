{ config, pkgs, ... }: {
  imports = [
    ./home-modules
  ];

        # services.ollama-container.enable = true;

  home.username = "david";
  home.homeDirectory = "/home/david";

  programs.git.enable = true;

  home.packages = with pkgs; [
  ];
  home.stateVersion = "23.11"; # or your current NixOS version
}


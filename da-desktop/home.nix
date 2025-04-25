{ config, pkgs, ... }: {
  imports = [
    ./home-modules
  ];

  services.ollama-container.enable = true;

  home.username = "david";
  home.homeDirectory = "/home/david";

  programs.git.enable = true;

  home.packages = with pkgs; [
  ];
services.udev.extraRules = ''
  ${builtins.readFile /home/david/Downloads/50-qmk.rules}
'';
        

  home.stateVersion = "23.11"; # or your current NixOS version
}


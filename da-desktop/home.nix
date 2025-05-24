{ config, pkgs, ... }: {
  imports = [
    ./home-modules
  ];

        # services.ollama-container.enable = true;

  home.username = "david";
  home.homeDirectory = "/home/david";
  programs.fish.enable = true;
  home.shell.enableFishIntegration = true;
  programs.zellij.enable = true;      
  programs.zellij.enableFishIntegration = false;
  programs.zellij.settings = {
    default_shell = "${pkgs.fish}/bin/fish";
  };




  programs.git.enable = true;

  home.packages = with pkgs; [
  ];
  home.stateVersion = "23.11"; # or your current NixOS version
}


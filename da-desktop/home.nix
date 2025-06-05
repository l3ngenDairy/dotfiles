{ config, pkgs, lib, ... }: {
  imports = [
  ];

  # Fix the conflicting homeDirectory definition
  home.username = "david";
  home.homeDirectory = lib.mkForce "/home/david";  # Force this value to resolve conflict
  
  programs.fish.enable = true;
  
  programs.zellij.enable = true;      
  programs.zellij.enableFishIntegration = true;
  programs.zellij.settings = {
    default_shell = "${pkgs.fish}/bin/fish";
  };

  programs.helix = {
    enable = true;
    settings = {
      theme = "gruvbox";
      editor = {
        line-number = "relative";
        cursorline = true;
        true-color = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        indent-guides = {
          render = true;
          character = "│";
        };
      };
    };
    languages = {
      language-server = {
        rust-analyzer = {
          command = "rust-analyzer";
        };
        nil = {
          command = "nil";
        };
      };

      language = [
        {
          name = "rust";
          language-servers = [ "rust-analyzer" ];
        }
        {
          name = "nix";
          language-servers = [ "nil" ];
        }
      ];
    };
  };

  home.packages = with pkgs; [
    rust-analyzer
    nil
    rustc
    cargo
    rustfmt            
    alejandra       
    lldb  
    age            
  ];

  programs.git.enable = true;

  home.stateVersion = "25.05";
}

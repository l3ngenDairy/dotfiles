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
  ];

  programs.git.enable = true;


  home.stateVersion = "23.11"; # or your current NixOS version
}


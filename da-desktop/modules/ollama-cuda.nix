{ config, pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      ollama = super.ollama.override { acceleration = "cuda"; };
    })
  ];

  environment.systemPackages = with pkgs; [
    ollama
    ollama-cuda
  ];

  environment.variables = {
    # Set OLLAMA_DIR to use the user's Documents folder
    OLLAMA_DIR = "${config.home.homeDirectory}/Documents/ollama-data";
  };
}


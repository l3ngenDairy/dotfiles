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
    # Dynamically use user's home directory
    OLLAMA_DIR = "$HOME/Documents/ollama-data";
  };



        
}

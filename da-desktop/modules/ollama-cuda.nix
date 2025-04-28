{ config, pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      ollama = super.ollama.override { acceleration = "cuda"; };
    })
  ];

  environment.systemPackages = with pkgs; [
    ollama
  ];

  environment.variables = {
    OLLAMA_DIR = "$HOME/Documents/ollama-data";
  };

  # Create the directory if it doesn't exist
  system.activationScripts.ollamaDir = let
    username = "david";  # Replace with your actual username
    group = "users";     # Or your primary group if different
  in ''
    mkdir -p ${config.environment.variables.OLLAMA_DIR}
    chown ${username}:${group} ${config.environment.variables.OLLAMA_DIR}
  '';
}

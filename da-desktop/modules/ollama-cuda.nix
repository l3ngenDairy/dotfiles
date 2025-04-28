{ config, pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      ollama = super.ollama.override { acceleration = "cuda"; };
    })
  ];

  environment.systemPackages = with pkgs; [
    ollama  # This will now be the CUDA version due to the overlay
  ];

  environment.variables = {
    OLLAMA_DIR = "$HOME/Documents/ollama-data";
  };

  # Create the directory if it doesn't exist
  system.activationScripts.ollamaDir = ''
    mkdir -p ${config.environment.variables.OLLAMA_DIR}
    chown ${config.users.users.${config.user}.name}:${config.users.groups.${config.user}.name} ${config.environment.variables.OLLAMA_DIR}
  '';
}

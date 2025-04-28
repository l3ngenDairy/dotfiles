{ config, pkgs, ... }:

let
  ollamaDataDir = "${config.home.homeDirectory}/Documents/ollama-data";
in {
  # Use a home-manager specific overlay
  nixpkgs.overlays = [
    (self: super: {
      ollama = super.ollama.override { 
        acceleration = "cuda";
      };
    })
  ];

  # Add Ollama to your packages - no need for explicit override here since we use the overlay
  home.packages = with pkgs; [
    ollama
    ollama-cuda            
  ];

  # Set environment variables
  home.sessionVariables = {
    OLLAMA_MODELS = "${ollamaDataDir}/models";
  };

  # Create the directory on activation
  home.activation.createOllamaDir = ''
    mkdir -p ${ollamaDataDir}/models
    chmod 700 ${ollamaDataDir}
  '';

  # Systemd user service
  systemd.user.services.ollama = {
    Unit.Description = "Ollama Service";
    Service = {
      # Use the ollama from our overlay
      ExecStart = "${pkgs.ollama}/bin/ollama serve";
      Restart = "always";
      WorkingDirectory = ollamaDataDir;
    };
    Install.WantedBy = ["default.target"];
  };
}

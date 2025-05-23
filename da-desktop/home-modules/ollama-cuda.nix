{ config, pkgs, ... }:

let
  ollamaDataDir = "${config.home.homeDirectory}/Documents/ollama-data";
in {
  # Add Ollama packages - using both the regular and CUDA-specific packages
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
      ExecStart = "${pkgs.ollama}/bin/ollama serve";
      Restart = "always";
      WorkingDirectory = ollamaDataDir;
    };
    Install.WantedBy = ["default.target"];
  };
}

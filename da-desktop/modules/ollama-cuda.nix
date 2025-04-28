{ config, pkgs, ... }:

let
  username = "david";  # Replace with your username
  ollamaDataDir = "/home/${username}/Documents/ollama-data";
in
{
  nixpkgs.overlays = [
    (self: super: {
      ollama = super.ollama.override { acceleration = "cuda"; };
    })
  ];

  environment.systemPackages = with pkgs; [
    ollama
  ];

  environment.sessionVariables = {
    OLLAMA_MODELS = "${ollamaDataDir}/models";
  };

  system.activationScripts.ollamaDir = ''
    mkdir -p ${ollamaDataDir}/models
    chown ${username}:users ${ollamaDataDir}
    chmod 700 ${ollamaDataDir}
  '';

  systemd.services.ollama = {
    serviceConfig = {
      Environment = "OLLAMA_MODELS=${ollamaDataDir}/models";
    };
  };
}

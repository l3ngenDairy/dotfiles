{ config, pkgs, lib, ... }:

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

  # Proper service configuration
  services.ollama = {
    enable = true;
    environmentVariables = {
      OLLAMA_MODELS = "${ollamaDataDir}/models";
    };
  };

  # Only needed if you need to override the package
  systemd.services.ollama = lib.mkIf config.services.ollama.enable {
    serviceConfig = {
      Environment = "OLLAMA_MODELS=${ollamaDataDir}/models";
      # If you need to run as your user rather than root:
      User = username;
      Group = "users";
    };
  };
}

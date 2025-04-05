{ config, pkgs, lib, ... }:

let
  username = config.home.username;
  homeDir = config.home.homeDirectory;
  ollamaDataDir = "${homeDir}/ollama-data";
in {
  options.services.ollama-container.enable = lib.mkEnableOption "Ollama container with GPU support";

  config = lib.mkIf config.services.ollama-container.enable {
    home.packages = with pkgs; [ podman ];

    home.activation.createOllamaDataDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p ${ollamaDataDir}
      chown ${username}:${username} ${ollamaDataDir}
    '';

    systemd.user.services.ollama = {
      Unit = {
        Description = "Ollama container";
        After = [ "network.target" ];
      };

      Service = {
        ExecStart = ''
          ${pkgs.podman}/bin/podman run --rm \
            --name ollama \
            --gpus all \
            -v ${ollamaDataDir}:/root/.ollama:Z \
            -p 11434:11434 \
            ollama/ollama:latest
        '';
        Restart = "always";
        RestartSec = 5;
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}


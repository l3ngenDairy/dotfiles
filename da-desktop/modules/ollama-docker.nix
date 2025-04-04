{ config, lib, pkgs, ... }:

let
  dockerImage = "ollama/ollama";
  containerName = "ollama";
  volumePath = "$HOME/ollama-data";  # Customize if you have a different path
  port = "11434";
in
{
  # The module automatically enables itself, no need for external `ollama.enable` in `configuration.nix`
  config = lib.mkIf true {  # Always enable the service

    systemd.services.docker-ollama = {
      description = "Ollama Docker Container";
      after = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = ''
          docker run -d --gpus=all -v ${volumePath}:/root/.ollama -p ${port}:${port} --name ${containerName} ${dockerImage}
        '';
        ExecStop = "docker stop ${containerName}";
        ExecStopPost = "docker rm ${containerName}";

        # Correct restart option for systemd
        Restart = "always";  # Ensure the service restarts if it stops
      };

    };
  };
}


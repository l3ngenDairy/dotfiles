{ config, lib, pkgs, ... }:

let
  dockerImage = "ollama/ollama";
  containerName = "ollama";
  volumePath = "$HOME/ollama-data";  # Customize if you have a different path
  port = 11434;
in
{
  options = {
    # Optional configuration parameters
    config.ollama.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable the Ollama Docker container.";
    };
  };

  config = lib.mkIf config.ollama.enable {
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
      };

      # Ensure the service is started on boot
      restart = "always";
    };
  };
}


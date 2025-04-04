{ config, pkgs, ... }:

{
  systemd.services.ollama-docker = {
    description = "Ollama container using Docker";
    after = [ "docker.service" "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStartPre = "${pkgs.docker}/bin/docker pull ollama/ollama";
      ExecStart = ''
        ${pkgs.docker}/bin/docker run --rm \
          --gpus all \
          --runtime=nvidia \
          --name ollama \
          -v ollama:/root/.ollama \
          -p 11434:11434 \
          ollama/ollama
      '';
      ExecStopPost = "${pkgs.docker}/bin/docker rm -f ollama || true";
      Restart = "always";
      RestartSec = 10;
    };
  };

  # Ensure Docker volume exists
  systemd.tmpfiles.rules = [
    "v /var/lib/docker/volumes/ollama 0755 david docker -"
  ];
}


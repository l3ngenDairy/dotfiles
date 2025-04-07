{ config, pkgs, lib, ... }:

let
  username = config.home.username;
  homeDir = config.home.homeDirectory;
  ollamaDataDir = "${homeDir}/ollama-data";

  ollamaImage = pkgs.dockerTools.pullImage {
    imageName = "ollama/ollama";
    finalImageTag = "0.1.28";
    imageDigest = "sha256:aefb5681bc87b8209f65f31e7042a2d5b159db8f6ac926665ca6964ae4519b9e";
    sha256 = "07n3s3gwfw2lgiz27xir8768p1y53c292jzdqjqrnpach06c56iv";
  };      
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
        ExecStartPre = [
          "${pkgs.podman}/bin/podman image exists ollama/ollama:0.1.28 || ${pkgs.podman}/bin/podman load < ${ollamaImage}"
        ];  
                                
        ExecStart = ''
          ${pkgs.podman}/bin/podman run --rm \
            --name ollama \
            --gpus all \
            -v ${ollamaDataDir}:/root/.ollama:Z \
            -p 11434:11434 \
            ollama/ollama:0.1.28
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


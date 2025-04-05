{ config, pkgs, lib, ... }:

let
  ollamaDataDir = "/home/david/ollama-data";
  uid = toString config.users.users.david.uid;
in {
  environment.systemPackages = with pkgs; [
    ollama
    podman
  ];

  # Correct GPU container support (using the new recommended way)
  hardware.nvidia-container-toolkit.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    # No longer need enableNvidia since we're using hardware.nvidia-container-toolkit.enable
  };

  systemd.tmpfiles.rules = [
    "d ${ollamaDataDir} 0755 david users - -"
  ];

  users.users.david.linger = true;

  # Correct way to define systemd user units in NixOS
  systemd.user = {
    services.ollama = {
      Unit = {
        Description = "Ollama Container Service";
        After = [ "network-online.target" "podman.socket" ];
        Requires = [ "podman.socket" ];
      };

      Service = {
        Type = "notify";
        ExecStart = "${pkgs.podman}/bin/podman run \
          --name ollama \
          --sdnotify=conmon \
          -p 11434:11434 \
          -v ${ollamaDataDir}:/root/.ollama:Z \
          --security-opt=label=disable \
          --gpus=all \
          ollama/ollama:latest";
        ExecStop = "${pkgs.podman}/bin/podman stop ollama";
        ExecStopPost = "${pkgs.podman}/bin/podman rm ollama";
        Restart = "always";
        RestartSec = "30s";
        TimeoutStartSec = "0";
        TimeoutStopSec = "120";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    # Correct socket definition
    sockets.podman = {
      Unit = {
        Description = "Podman API Socket";
      };
      Socket = {
        ListenStream = "%t/podman/podman.sock";
        SocketMode = "0660";
      };
      Install = {
        WantedBy = [ "sockets.target" ];
      };
    };
  };
}

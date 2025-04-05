{ config, pkgs, lib, ... }:

let
  ollamaDataDir = "/home/david/ollama-data";
  uid = toString config.users.users.david.uid;
in {
  environment.systemPackages = with pkgs; [
    ollama
    podman
  ];

  hardware.nvidia-container-toolkit.enable = true;
  virtualisation.podman = {
    enable = true;
    enableNvidia = true;
    dockerCompat = true;
  };

  systemd.tmpfiles.rules = [
    "d ${ollamaDataDir} 0755 david users - -"
  ];

  users.users.david.linger = true;

  systemd.user.services.ollama = {
    description = "Ollama Container Service";
    wantedBy = [ "default.target" ];
    after = [ "network-online.target" "podman.socket" ];
    requires = [ "podman.socket" ];

    serviceConfig = {
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
      WatchdogSec = "0";
    };

    environment = {
      XDG_RUNTIME_DIR = "/run/user/${uid}";
      DOCKER_HOST = "unix:///run/user/${uid}/podman/podman.sock";
    };
  };

  # Explicit socket creation
  systemd.user.sockets.podman = {
    Unit.Description = "Podman API Socket";
    Socket.ListenStream = "%t/podman/podman.sock";
    Socket.SocketMode = "0660";
    Install.WantedBy = [ "sockets.target" ];
  };
}

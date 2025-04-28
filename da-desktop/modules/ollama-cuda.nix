{ config, pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      ollama = super.ollama.override { acceleration = "cuda"; };
    })
  ];

  environment.systemPackages = with pkgs; [
    ollama
    ollama-cuda
  ];

  systemd.user.services.ollama-wrapper = {
    Unit = {
      Description = "Ollama with custom data dir";
      After = [ "network.target" ];
    };

    Service = {
      ExecStart = ''
        ${pkgs.ollama}/bin/ollama serve
      '';
      Environment = "OLLAMA_DIR=%h/Documents/ollama-data";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}


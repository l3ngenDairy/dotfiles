{ pkgs, ... }:
{
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = false;
      setSocketVariable = true;
    };
    daemon.settings = {
      "default-runtime" = "nvidia";
      "runtimes" = {
        "nvidia" = {
          "path" = "nvidia-container-runtime";
          "runtimeArgs" = [];
        };
      };
      "default-address-pools" = [
        { "base" = "172.27.0.0/16"; "size" = 24; }
      ];
    };
  };

  users.users.david.extraGroups = [ "docker" ];

  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}


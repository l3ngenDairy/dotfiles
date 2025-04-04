{ pkgs, ... }:
{
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
    daemon.settings = {
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

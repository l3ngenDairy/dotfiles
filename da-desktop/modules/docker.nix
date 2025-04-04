{ pkgs, ... }:
{
  virtualisation.docker = {
    enable = true;
    # Remove enableNvidia since it's deprecated
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
    daemon.settings = {
      "default-address-pools" = [
        { "base" = "172.27.0.0/16"; "size" = 24; }
      ];
      # Remove the entire runtimes section
    };
  };
  
  users.users.david.extraGroups = [ "docker" ];
  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}

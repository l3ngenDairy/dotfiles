{ pkgs, ... }:
{
  virtualisation.docker = {
    enable = true;
    # Remove enableNvidia since it's deprecated
    rootless = {
      enable = false;
      setSocketVariable = true;
    };
    daemon.settings = {
      "default-address-pools" = [
        { "base" = "172.27.0.0/16"; "size" = 24; }
      ];
      # Remove the entire runtimes section 

"runtimes" = {
    "nvidia" = {
    "path" = "${pkgs.dockerTools.nvidia-container-runtime}/bin/nvidia-container-runtime";
    "runtimeArgs" = [];
    };
  };


    };
  };
  
  users.users.david.extraGroups = [ "docker" ];
  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}

{ pkgs, ... }:
{
  virtualisation.docker = {
    enable = true;
    enableNvidia = true;  # This is crucial
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
    daemon.settings = {
      "default-address-pools" = [
        { "base" = "172.27.0.0/16"; "size" = 24; }
      ];
      "runtimes" = {
        "nvidia" = {
          "path" = "${pkgs.nvidia-container-toolkit}/bin/nvidia-container-runtime";
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

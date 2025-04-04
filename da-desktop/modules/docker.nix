{ pkgs, ... }:
{
  # Enable Docker
  virtualisation.docker = {
    enable = true;
    
    # Enable rootless mode
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
    
    # Rest of your configuration...
    daemon.settings = {
      "default-address-pools" = [
        { "base" = "172.27.0.0/16"; "size" = 24; }
      ];
    };
  };
  
  # You can keep this, but it's less important with rootless Docker
  users.users.david.extraGroups = [ "docker" ];
  
  # Optional: Install docker-compose
  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}

#{ pkgs, ... }:{
  # Enable Docker
#  virtualisation.docker = {
#    enable = true;
    
    # Optional: Enable rootless mode
    # rootless = {
    #   enable = true;
    #   setSocketVariable = true;
    # };
    
    # Optional: Set storage driver for btrfs
    # storageDriver = "btrfs";
    
    # Optional: Configure daemon settings
#   daemon.settings = {
      # Optional: Custom data root
      # "data-root" = "/some-place/to-store-the-docker-data";
      
      # Optional: Configure address pools to avoid WiFi conflicts
#     "default-address-pools" = [
#       { "base" = "172.27.0.0/16"; "size" = 24; }
#     ];
      
      # Add other settings as needed
      # "log-driver" = "json-file";
      # "log-opts" = {
      #   "max-size" = "10m";
      #   "max-file" = "3";
      # };
#   };
# };
  
  # Add users to the docker group (replace username with your actual username)
# users.users.david.extraGroups = [ "docker" ];
  
  # Optional: Install docker-compose
# environment.systemPackages = with pkgs; [
        #    docker-compose
        # ];
  
  # Optional: Add systemd services for containers
  # virtualisation.oci-containers = {
  #   backend = "docker";
  #   containers = {
  #     example-container = {
  #       image = "example/image:latest";
  #       ports = ["127.0.0.1:8080:80"];
  #       volumes = [
  #         "/path/on/host:/path/in/container"
  #       ];
  #     };
  #   };
  # };
#}


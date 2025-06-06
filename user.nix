{ pkgs, config, ... }:

{  
   # Location of your Age secret key
  sops.age.keyFile = "/home/david/.config/sops/age/keys.txt";
        
  programs.fish.enable = true;

  users = {
    defaultUserShell = pkgs.fish;

    users.david = {
      isNormalUser = true;
      description = "david";
      extraGroups = [ "networkmanager" "wheel" "input" "libvirtd" "libvirt" "docker" "podman" "kvm" ];
      packages = with pkgs; [ fish ];

      # Use the decrypted sops secret for the password:
      hashedPasswordFile = config.sops.secrets.userPassword.path;
    };

    users.admin = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
  };

  # Declare the sops secret here, matching the key in secrets.yaml:
  sops.secrets.userPassword = {
    sopsFile = ./secrets/secrets.yaml;
    key = "user-password";
  };

  # Enable automatic login for david
  services.getty.autologinUser = "david";
}


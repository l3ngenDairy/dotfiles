{ pkgs, ... }: {
  programs.zsh.enable = true;
  programs.fish.enable = true;
  users = {
    defaultUserShell = pkgs.fish;

    users.david = {
      isNormalUser = true;
      description = "david";
      extraGroups = [ "networkmanager" "wheel" "input" "libvirtd" "libvirt" "docker" "podman" "kvm" "plugdev" ];
      packages = with pkgs; [fish];
    };
  };

  # Enable automatic login for the user.
   services.getty.autologinUser = "david";
}

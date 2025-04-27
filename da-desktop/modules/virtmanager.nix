{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    libvirt
    qemu
    spice-vdagent
    virt-manager 
  ];
  
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      ovmf.enable = true;
      runAsRoot = true;
    };
  };
  
  systemd.services.libvirtd-network-default = {
    enable = true;
    description = "Libvirt Default Network Auto-Start";
    wantedBy = [ "multi-user.target" ];
    requires = [ "libvirtd.service" ];
    after = [ "libvirtd.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
    };
    script = ''
      if ! ${pkgs.libvirt}/bin/virsh net-info default | grep -q "Active:.*yes"; then
        ${pkgs.libvirt}/bin/virsh net-start default
      fi
      ${pkgs.libvirt}/bin/virsh net-autostart default
    '';
  };
  
  systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0666 - - - -"
  ];
  
  programs.virt-manager = {
    enable = true;
    package = pkgs.virt-manager;
  };

  ### 🛠 Optimization tweaks start here:



  systemd.services."libvirt-guests" = {
    enable = false;
  };

}


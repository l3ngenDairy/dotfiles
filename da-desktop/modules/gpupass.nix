{ config, lib, pkgs, ... }:

let
  gpuIDs = [
    "10de:2482" # NVIDIA RTX 3070 Ti Graphics
    "10de:228b" # NVIDIA HD Audio Controller
  ];
  # IOMMU Group 16 contains USB controllers
  # Using AMD 500 Series Chipset USB 3.1 XHCI Controller
  gpuUsbDriverId = "0000:02:00.0"; 
in
{
  options = { };
  config = {
    boot.kernelModules = [ "msr" "vfio-pci" "vfio_iommu_type1" "vfio" ];

    boot.kernelParams = [
      "nohibernate"
      "init_on_alloc=0"
      "amd_iommu=on" # Changed from intel_iommu as you have AMD CPU
      "iommu=pt"
      "console=tty1"
      "vfio-pci.ids=${builtins.concatStringsSep "," gpuIDs}"
    ];

    services.udev.extraRules = ''
      SUBSYSTEM=="vfio", OWNER="root", GROUP="kvm"
    '';

    # This service unbinds the USB controller from its current driver and binds it to vfio-pci
    systemd.services.forceRebindUSB = {
      enable = true;
      description = "Force rebind USB controller to VFIO";
      wantedBy = [ "multi-user.target" ];
      script = ''
        echo -n "${gpuUsbDriverId}" > /sys/bus/pci/drivers/xhci_hcd/unbind
        echo -n "${gpuUsbDriverId}" > /sys/bus/pci/drivers/vfio-pci/bind
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };
  };
}

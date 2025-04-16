{ config, lib, pkgs, ... }:

with lib;

{
  options.services.single-gpu-passthrough = {
    enable = mkEnableOption "Single GPU passthrough VFIO setup";
  };

  config = mkIf config.services.single-gpu-passthrough.enable {
    environment.etc = {
      "libvirt/hooks/qemu" = {
        text = ''
          #!/usr/bin/env bash
          VM_NAME="$1"
          VM_ACTION="$2"
          
          if [ "$VM_NAME" = "gaming-vm" ]; then
            if [ "$VM_ACTION" = "prepare" ]; then
              # Stop display manager
              systemctl stop display-manager
              
              # Unbind GPU from host
              echo 0000:06:00.0 > /sys/bus/pci/devices/0000:06:00.0/driver/unbind
              echo 0000:06:00.1 > /sys/bus/pci/devices/0000:06:00.1/driver/unbind
              
              # Bind to VFIO
              echo 10de 2482 > /sys/bus/pci/drivers/vfio-pci/new_id
              echo 10de 228b > /sys/bus/pci/drivers/vfio-pci/new_id
            elif [ "$VM_ACTION" = "release" ]; then
              # Unbind from VFIO
              echo 0000:06:00.0 > /sys/bus/pci/drivers/vfio-pci/unbind
              echo 0000:06:00.1 > /sys/bus/pci/drivers/vfio-pci/unbind
              
              # Rebind to NVIDIA driver
              echo 10de 2482 > /sys/bus/pci/drivers/nvidia/new_id
              echo 10de 228b > /sys/bus/pci/drivers/snd_hda_intel/new_id
              
              # Restart display manager
              systemctl start display-manager
            fi
          fi
        '';
        mode = "0755";
      };
    };
    
    # Required kernel modules for VFIO
    boot.kernelModules = [ "vfio_pci" "vfio" "vfio_iommu_type1" "vfio_virqfd" ];
    
    # Required kernel parameters for IOMMU
    boot.kernelParams = [
      "amd_iommu=on"
      "iommu=pt"
    ];
  };
}

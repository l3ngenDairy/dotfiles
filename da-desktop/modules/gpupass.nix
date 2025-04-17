{ config, lib, pkgs, ... }: 

let
  gpuIDs = [
    "10de:2482" # NVIDIA RTX 3070 Ti Graphics
    "10de:228b" # NVIDIA HD Audio Controller
  ];
  
  # IOMMU Group 16 contains USB controllers
  # Using AMD 500 Series Chipset USB 3.1 XHCI Controller
  gpuUsbDriverId = "0000:02:00.0";
  
  # Create scripts to bind/unbind devices
  vfioBindScript = pkgs.writeShellScript "vfio-bind" ''
    # Unbind GPU from nvidia and bind to vfio
    for dev in ${builtins.concatStringsSep " " gpuIDs}; do
      vendor=$(echo $dev | cut -d ':' -f1)
      device=$(echo $dev | cut -d ':' -f2)
      if [ -e /sys/bus/pci/devices/*:*:*.*/driver/unbind ]; then
        echo "Unbinding $vendor:$device from nvidia driver"
        echo -n "*:*:*.0" > /sys/bus/pci/drivers/nvidia/unbind 2>/dev/null || true
        echo -n "*:*:*.1" > /sys/bus/pci/drivers/snd_hda_intel/unbind 2>/dev/null || true
      fi
      echo "$vendor $device" > /sys/bus/pci/drivers/vfio-pci/new_id
    done

    # Optionally also bind USB controller
    if [ "${gpuUsbDriverId}" != "" ]; then
      echo "Unbinding USB controller from xhci_hcd"
      echo -n "${gpuUsbDriverId}" > /sys/bus/pci/drivers/xhci_hcd/unbind || true
      echo -n "${gpuUsbDriverId}" > /sys/bus/pci/drivers/vfio-pci/bind || true
    fi
  '';

  vfioUnbindScript = pkgs.writeShellScript "vfio-unbind" ''
    # Unbind from vfio and let the normal drivers claim the devices
    for dev in ${builtins.concatStringsSep " " gpuIDs}; do
      vendor=$(echo $dev | cut -d ':' -f1)
      device=$(echo $dev | cut -d ':' -f2)
      echo "$vendor $device" > /sys/bus/pci/drivers/vfio-pci/remove_id 2>/dev/null || true
    done
    
    # Trigger device discovery to rebind native drivers
    echo 1 > /sys/bus/pci/rescan

    # Optionally also unbind USB controller
    if [ "${gpuUsbDriverId}" != "" ]; then
      echo -n "${gpuUsbDriverId}" > /sys/bus/pci/drivers/vfio-pci/unbind || true
      echo -n "${gpuUsbDriverId}" > /sys/bus/pci/drivers/xhci_hcd/bind || true
    fi
  '';

in {
  options = { };
  
  config = {
    # Required kernel modules for VFIO
    boot.kernelModules = [ "msr" "vfio-pci" "vfio_iommu_type1" "vfio" ];
    
    # Note: We're not adding the GPU IDs to vfio-pci.ids parameter anymore
    boot.kernelParams = [
      "nohibernate"
      "init_on_alloc=0"
      "amd_iommu=on" # Changed from intel_iommu as you have AMD CPU
      "iommu=pt"
      "console=tty1"
    ];
    
    services.udev.extraRules = ''
      SUBSYSTEM=="vfio", OWNER="root", GROUP="kvm"
    '';
    
    # Make scripts available in the system
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "bind-vfio-gpu" ''
        if [ "$EUID" -ne 0 ]; then
          echo "Please run as root"
          exit 1
        fi
        ${vfioBindScript}
        echo "GPU bound to VFIO driver"
      '')
      
      (pkgs.writeShellScriptBin "unbind-vfio-gpu" ''
        if [ "$EUID" -ne 0 ]; then
          echo "Please run as root"
          exit 1
        fi
        ${vfioUnbindScript}
        echo "GPU released from VFIO driver"
      '')
    ];
    
    # Hook into libvirt to automatically bind/unbind the GPU when VM starts/stops
    virtualisation.libvirtd = {
      enable = true;
      hooks.qemu = {
        "bind-vfio" = pkgs.writeShellScript "libvirt-hook-qemu-bind-vfio" ''
          VM_NAME="$1"
          VM_ACTION="$2"
          
          # Add your VM name here - only bind for this specific VM
          TARGET_VM="win10" # Change this to your VM name
          
          if [ "$VM_NAME" = "$TARGET_VM" ]; then
            if [ "$VM_ACTION" = "prepare" ]; then
              echo "Binding GPU to VFIO for VM $VM_NAME"
              ${vfioBindScript}
            elif [ "$VM_ACTION" = "release" ]; then
              echo "Releasing GPU from VFIO after VM $VM_NAME shutdown"
              ${vfioUnbindScript}
            fi
          fi
        '';
      };
    };
  };
}

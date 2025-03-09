{ config, lib, pkgs, ... }:

let
  detectGpu = pkgs.runCommand "detect-gpu" {} ''
    if ${pkgs.pciutils}/bin/lspci | grep -qi "nvidia"; then
      echo "nvidia" > $out
    elif ${pkgs.pciutils}/bin/lspci | grep -qi "amd"; then
      echo "amd" > $out
    else
      echo "unknown" > $out
    fi
  '';
in {
  options.hardware.gpu.vendor = lib.mkOption {
    type = lib.types.str;
    default = "unknown";
    description = "Detected GPU vendor (nvidia, amd, or unknown)";
  };

  config = {
    hardware.gpu.vendor = lib.mkDefault (builtins.readFile detectGpu);

    # Basic GPU settings
    services.xserver.enable = true;
    hardware.opengl.enable = true;
  };
}

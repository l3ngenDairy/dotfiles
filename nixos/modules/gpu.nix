# gpu.nix
{ config, pkgs, lib, ... }:
let
  # Detect GPU vendor using lspci
  detectGpuVendor = pkgs.runCommand "detect-gpu-vendor" { buildInputs = [ pkgs.pciutils ]; } ''
    if lspci | grep -qi "nvidia"; then
      echo "nvidia" > $out
    elif lspci | grep -qi "amd"; then
      echo "amd" > $out
    else
      echo "unknown" > $out
    fi
  '';

  gpuVendor = lib.removeSuffix "\n" (builtins.readFile detectGpuVendor);

  # Import the appropriate GPU configuration based on detection
  gpuConfig =
    if gpuVendor == "nvidia" then
      import ./nvidia.nix
    else if gpuVendor == "amd" then
      import ./amd.nix
    else
      { };
in
{
  imports = [
    gpuConfig
  ];

  # Fallback or default configuration
  services.xserver.enable = true;
  hardware.opengl.enable = true;
}

{ config, pkgs, lib, ... }:
let
  # Detect the GPU vendor based on loaded kernel modules
  gpuVendor =
    if lib.lists.any (x: lib.strings.hasInfix "nvidia" x) config.boot.kernelModules then
      "nvidia"
    else if lib.lists.any (x: lib.strings.hasInfix "amdgpu" x) config.boot.kernelModules then
      "amd"
    else
      "unknown";

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

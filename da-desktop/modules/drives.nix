{ lib, ... }:
{
  services.fstrim.enable = true;

  fileSystems = {
    "/media/drive-1" = {
      device = "/dev/disk/by-uuid/61d1bd2e-1784-4aea-a561-7198ae6b6829";
      fsType = "ext4";
      options = [ "defaults" "nofail" "users" "exec" ];
    };

    "/media/drive-2" = {
      device = "/dev/disk/by-uuid/c54e517e-44cc-4a7e-9230-0905134ee93f";
      fsType = "ext4";
      options = [ "defaults" "nofail" "users" "exec" ];
    };
  };
}


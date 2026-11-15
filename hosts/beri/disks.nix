{
  den.aspects.beri.nixos.fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
      fsType = "ext4";
    };

    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
      options = ["noatime" "noauto" "x-systemd.automount" "x-systemd.idle-timeout=1min"];
    };
  };
}

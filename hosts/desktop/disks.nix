_: {
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/4ad58569-dc27-413c-8a66-0a8922423368";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/72e883cf-9584-4507-bb6f-c1a64e42c553";
    fsType = "ext4";
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/840F-2D62";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/b4490d33-066d-4591-b1a0-921324a2c388";}
  ];
}

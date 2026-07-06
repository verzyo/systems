{inputs, ...}: {
  imports = [inputs.disko.nixosModules.disko];

  disko.devices.disk.main = {
    device = "/dev/disk/by-id/nvme-CT1000P2SSD8_2130E5BB2322";
    type = "disk";

    content = {
      type = "gpt";

      partitions = {
        EFI = {
          size = "1G";
          type = "EF00";

          content = {
            type = "filesystem";
            format = "vfat";

            mountpoint = "/boot";
            mountOptions = ["umask=0077"];
          };
        };

        root = {
          size = "100%";

          content = {
            type = "filesystem";
            format = "ext4";

            mountpoint = "/";
          };
        };
      };
    };
  };
}

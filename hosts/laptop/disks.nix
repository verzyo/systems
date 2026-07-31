{
  inputs,
  config,
  ...
}: let
  # ls -l /dev/disk/by-id
  device = "/dev/disk/by-id/nvme-CT1000P2SSD8_2130E5BB2322"; #FIXME

  preservation = config.modules.preservation;
in {
  imports = [inputs.disko.nixosModules.disko];

  modules.preservation = {
    enable = true;
    rootPartitionPath = "${device}-part2"; #FIXME

    preservedSubvolume = "pres";
    snapshotSubvolume = "snap";
  };

  disko.devices.disk.main = {
    inherit device;
    type = "disk";

    #FIXME
    content = {
      type = "gpt";

      # boot partitions, 1GB at the start
      partitions = {
        EFI = {
          size = "1G";
          type = "EF00";
          priority = 1;

          content = {
            type = "filesystem";
            format = "vfat";

            mountpoint = "/boot";
            mountOptions = ["umask=0077"];
          };
        };

        # root partition taking remaining space
        root = {
          start = "1025MiB";
          end = "-16G";

          priority = 2;

          content = {
            type = "btrfs";

            extraArgs = ["-f" "-L" "NIXOS"];

            subvolumes = {
              "@home" = {
                mountpoint = "/home";
                mountOptions = ["compress=zstd" "noatime"];
              };
              "@${preservation.preservedSubvolume}" = {
                mountpoint = "/${preservation.preservedSubvolume}";
                mountOptions = ["compress=zstd" "noatime"];
              };
              "@${preservation.snapshotSubvolume}" = {
                mountpoint = "/${preservation.snapshotSubvolume}";
                mountOptions = ["compress=zstd" "noatime"];
              };
              "@nix" = {
                mountpoint = "/nix";
                mountOptions = ["compress=zstd" "noatime"];
              };
              "@root" = {
                mountpoint = "/";
                mountOptions = ["compress=zstd" "noatime"];
              };
            };
          };
        };

        # swap partition, takes 16GB at the very end of the disk
        swap = {
          name = "swap";
          type = "8200";

          start = "-16G";
          size = "16G";

          priority = 3;

          content = {
            type = "swap";

            resumeDevice = true;
            discardPolicy = "once";

            extraArgs = ["-L" "SWAP"];
          };
        };
      };
    };
  };
}

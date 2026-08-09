{
  inputs,
  config,
  ...
}: let
  # ls -l /dev/disk/by-id
  device = "/dev/disk/by-id/nvme-CT1000P2SSD8_2130E5BB2322"; #FIXME
  luksDeviceName = "crypted"; #FIXME can be anything

  preservation = config.modules.preservation;
in {
  imports = [inputs.disko.nixosModules.disko];

  #FIXME
  modules.preservation = {
    enable = true;

    rootPartitionPath = "/dev/mapper/${luksDeviceName}";
    #rootPartitionPath = "${device}-part2";

    preservedSubvolume = "pres";
    snapshotSubvolume = "snap";
  };

  # zram swap
  zramSwap.enable = true;

  # required for TPM unlocking
  boot.initrd = {
    systemd.enable = true;
    luks.devices.${luksDeviceName}.crypttabExtraOpts = ["tpm2-device=auto"];
  };

  disko.devices.disk.main = {
    inherit device;
    type = "disk";

    #FIXME
    content = {
      type = "gpt";

      partitions = {
        # boot partition, 1GB at the start
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
            type = "luks";
            name = luksDeviceName;

            settings.allowDiscards = true;

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
        };

        # swap partition, takes 16GB at the very end of the disk
        swap = {
          start = "-16G";
          size = "16G";

          name = "swap";
          type = "8200";

          priority = 3;

          content = {
            type = "swap";

            discardPolicy = "once";
            extraArgs = ["-L" "SWAP"];

            randomEncryption = true;
          };
        };
      };
    };
  };
}

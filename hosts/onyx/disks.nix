{inputs, ...}: {
  nixos.configurations.onyx.module = let
    luksDeviceName = "crypted";
  in {
    imports = [inputs.disko.nixosModules.default];

    # required for TPM unlocking
    boot.initrd.luks.devices.${luksDeviceName}.crypttabExtraOpts = ["tpm2-device=auto"];

    disko.devices.disk.main = {
      # ls -l /dev/disk/by-id
      device = "/dev/disk/by-id/nvme-CT1000P2SSD8_2130E5BB2322";
      type = "disk";

      content = {
        type = "gpt";

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
                  "@pres" = {
                    mountpoint = "/pres";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "@snap" = {
                    mountpoint = "/snap";
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

          swap = {
            start = "-16G";
            size = "16G";
            priority = 3;

            name = "swap";
            type = "8200";

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
  };
}

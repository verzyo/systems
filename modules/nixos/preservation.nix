{
  inputs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.preservation;
in {
  imports = [inputs.preservation.nixosModules.preservation];

  config = lib.mkIf cfg.enable {
    preservation = {
      enable = true;

      preserveAt."/${cfg.preservedSubvolume}" = {
        directories = [
          "/var/lib/nixos"
          "/var/log"
          "/var/lib/systemd/timers"
          "/var/lib/systemd/coredump"
        ];

        files = [
          {
            file = "/etc/machine-id";
            inInitrd = true;
          }
        ];
      };
    };

    systemd.suppressedSystemUnits = ["systemd-machine-id-commit.service"];

    fileSystems = {
      "/nix".neededForBoot = true;
      "/${cfg.preservedSubvolume}".neededForBoot = true;
    };

    boot.initrd.systemd = {
      enable = true;

      services.ephemerality = {
        description = "Ephemerality service";

        wantedBy = ["initrd-root-fs.target"];
        before = ["sysroot.mount"];
        after = ["initrd-root-device.target"];

        unitConfig.DefaultDependencies = false;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };

        script = ''
          mkdir -p /mnt
          mount ${cfg.rootPartitionPath} /mnt

          delete_subvolume_recursively() {
            IFS=$'\n'

            for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
              delete_subvolume_recursively "/mnt/$i"
            done

            btrfs subvolume delete "$1"
          }

          if [ -e /mnt/@${cfg.snapshotSubvolume} ]; then
            delete_subvolume_recursively "/mnt/@${cfg.snapshotSubvolume}"
          fi

          if [ -e /mnt/@${cfg.rootSubvolume} ]; then
            mv /mnt/@${cfg.rootSubvolume} /mnt/@${cfg.snapshotSubvolume}
          fi

          btrfs subvolume create /mnt/@${cfg.rootSubvolume}
          umount /mnt
        '';
      };
    };

    users.mutableUsers = false;
    security.sudo.extraConfig = "Defaults lecture = never";
  };

  options.modules.preservation = {
    enable = lib.mkEnableOption "preservation module";

    rootPartitionPath = lib.mkOption {
      type = lib.types.str;
      description = "The root partition /dev/disk/by-id/ or /dev/mapper/ identifier";
    };

    rootSubvolume = lib.mkOption {
      type = lib.types.str;
      default = "root";
      description = "Name of the ephemeral root subvolume";
    };

    preservedSubvolume = lib.mkOption {
      type = lib.types.str;
      default = "preserved";
      description = "Name of the preserved state subvolume";
    };

    snapshotSubvolume = lib.mkOption {
      type = lib.types.str;
      default = "snapshot";
      description = "Name of the subvolume containing the previous boot state";
    };
  };
}

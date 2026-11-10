{den, ...}: {
  den.aspects.ephemeral.btrfs = {
    includes = [den.aspects.ephemeral];

    nixos = {
      lib,
      config,
      ...
    }: let
      subvolume = path: let
        fs = config.fileSystems.${path} or (throw "ephemeral: ${config.networking.hostName} has no ${path} filesystem");
        option = lib.findFirst (lib.hasPrefix "subvol=") (throw "ephemeral: ${path} is not mounted from a btrfs subvolume") fs.options;
      in
        lib.removePrefix "/" (lib.removePrefix "subvol=" option);

      inherit (config.fileSystems."/") device fsType;
      root = subvolume "/";
      previous = subvolume "/snap";
    in {
      assertions = [
        {
          assertion = fsType == "btrfs";
          message = "${config.networking.hostName}: ephemeral.btrfs needs a btrfs root, found ${fsType}";
        }
      ];

      boot.initrd.systemd.services.ephemerality = {
        description = "Move the previous root aside and create a fresh one.";

        wantedBy = ["initrd-root-fs.target"];
        before = ["sysroot.mount"];
        after = ["initrd-root-device.target"];

        unitConfig.DefaultDependencies = false;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };

        # subvolid=5 is the top level, whatever the default subvolume is
        script = ''
          mkdir -p /mnt
          mount -o subvolid=5 ${device} /mnt

          if [ -e /mnt/${previous} ]; then
            btrfs subvolume delete --recursive /mnt/${previous}
          fi

          if [ -e /mnt/${root} ]; then
            mv /mnt/${root} /mnt/${previous}
          fi

          btrfs subvolume create /mnt/${root}
          umount /mnt
        '';
      };
    };
  };
}

{
  nixos.modules.preservation = {
    config,
    lib,
    ...
  }: let
    subvolume = path: let
      fs = config.fileSystems.${path} or (throw "preservation-btrfs: ${config.networking.hostName} has no ${path} filesystem");
      option = lib.findFirst (lib.hasPrefix "subvol=") (throw "preservation-btrfs: ${path} is not mounted from a btrfs subvolume") fs.options;
    in
      lib.removePrefix "/" (lib.removePrefix "subvol=" option);

    device = config.fileSystems."/".device;
    root = subvolume "/";
    previous = subvolume "/snap";
  in
    lib.mkIf (config.ephemeral.root == "btrfs") {
      boot.initrd.systemd.services.ephemerality = {
        description = "Move the previous root aside and create a fresh one";

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
}

{inputs, ...}: {
  nixos.modules.ephemeral = {
    lib,
    config,
    ...
  }: let
    preservationState = config.preservation.preserveAt.state;
    fsType = config.fileSystems."/".fsType;
  in {
    imports = [inputs.preservation.nixosModules.default];

    preservation = {
      enable = true;

      preserveAt.state = {
        persistentStoragePath = lib.mkDefault "/pres";

        directories = [
          {
            directory = "/var/lib/nixos";
            inInitrd = true;
          }
          {
            directory = "/var/lib/systemd/timesync";
            user = "systemd-timesync";
            group = "systemd-timesync";
          }
          "/var/log"
          "/var/lib/systemd/timers"
          "/var/lib/systemd/backlight"
        ];

        files = [
          {
            file = "/etc/machine-id";
            inInitrd = true;
          }
          {
            file = "/var/lib/systemd/random-seed";
            how = "symlink";
            inInitrd = true;
            configureParent = true;
          }
        ];
      };
    };

    systemd.suppressedSystemUnits = ["systemd-machine-id-commit.service"];

    fileSystems = {
      "/nix".neededForBoot = true;
      ${preservationState.persistentStoragePath}.neededForBoot = true;
    };

    # /etc is wiped on boot, keep the uid/gid allocation on persisted state
    services.userborn.passwordFilesLocation =
      lib.mkIf config.services.userborn.enable
      "/var/lib/nixos";

    users.mutableUsers = false;
    security.sudo.extraConfig = "Defaults lecture = never";

    assertions = [
      {
        assertion = lib.elem fsType ["btrfs"];
        message = "${config.networking.hostName}: ephemeral can't wipe a ${fsType} root, supported: btrfs";
      }
    ];
  };
}

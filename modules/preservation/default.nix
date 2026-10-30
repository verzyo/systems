{inputs, ...}: {
  nixos.modules.base.imports = [inputs.preservation.nixosModules.default];

  nixos.modules.preservation = {
    config,
    lib,
    ...
  }: let
    state = config.preservation.preserveAt.state;
  in {
    options.ephemeral.root = lib.mkOption {
      type = lib.types.enum ["btrfs" "tmpfs"]; # tmpfs wipes itself
      default = config.fileSystems."/".fsType;
      defaultText = lib.literalExpression ''config.fileSystems."/".fsType'';
      description = ''
        How the root filesystem is wiped on boot, detected from its fsType.
        Backends gate on this, so they must not define fileSystems themselves.
      '';
    };

    config = {
      preservation = {
        enable = true;

        preserveAt.state = {
          persistentStoragePath = lib.mkDefault "/pres";

          directories = [
            {
              directory = "/var/lib/nixos";
              inInitrd = true;
            }
            "/var/log"
            "/var/lib/systemd/timers"
            "/var/lib/systemd/coredump"
            "/var/lib/systemd/backlight"
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
        ${state.persistentStoragePath}.neededForBoot = true;
      };

      # /etc is wiped on boot, keep the uid/gid allocation on persisted state
      services.userborn.passwordFilesLocation = lib.mkIf config.services.userborn.enable "/var/lib/nixos";

      users.mutableUsers = false;
      security.sudo.extraConfig = "Defaults lecture = never";
    };
  };
}

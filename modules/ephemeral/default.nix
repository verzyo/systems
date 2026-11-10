{inputs, ...}: {
  flake-file.inputs.preservation.url = "github:nix-community/preservation";

  den.quirks.persist.description = "System paths kept on /pres across reboots";

  den.aspects.ephemeral = {
    nixos = {
      persist,
      lib,
      ...
    }: let
      collect = kind: lib.unique (lib.concatMap (entry: entry.${kind} or []) persist);
    in {
      imports = [inputs.preservation.nixosModules.default];

      preservation = {
        enable = true;

        preserveAt."/pres" = {
          directories = collect "directories";
          files = collect "files";
        };
      };

      # the machine id lives on /pres, committing it to / would be wiped anyway
      systemd.suppressedSystemUnits = ["systemd-machine-id-commit.service"];

      fileSystems = {
        "/nix".neededForBoot = true;
        "/pres".neededForBoot = true;
      };

      users.mutableUsers = false;
      security.sudo.extraConfig = "Defaults lecture = never";
    };

    persist = {
      directories = [
        {
          directory = "/var/lib/nixos";
          inInitrd = true;
        }
        "/var/log"
        "/var/lib/systemd/timers"
        "/var/lib/systemd/backlight"
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
}

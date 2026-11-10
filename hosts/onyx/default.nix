{den, ...}: {
  den = {
    hosts.x86_64-linux.onyx.users.verz = {};

    aspects.onyx = {
      includes = with den.aspects; [
        ephemeral.btrfs

        plymouth
        lanzaboote
      ];

      nixos = {
        hardware.facter.reportPath = ./hardware.json;
        system.stateVersion = "26.11";
      };
    };
  };
}

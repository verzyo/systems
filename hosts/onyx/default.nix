{den, ...}: {
  den = {
    hosts.x86_64-linux.onyx = {};

    aspects.onyx = {
      includes = with den.aspects; [
        lanzaboote
        plymouth
      ];

      nixos = {
        hardware.facter.reportPath = ./hardware.json;
        system.stateVersion = "26.11";
      };
    };
  };
}

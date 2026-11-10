{den, ...}: {
  den = {
    hosts.x86_64-linux.onyx = {};

    aspects.onyx = {
      includes = [den.aspects.lanzaboote];

      nixos = {
        hardware.facter.reportPath = ./hardware.json;
        system.stateVersion = "26.11";
      };
    };
  };
}

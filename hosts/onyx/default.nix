{den, ...}: {
  den = {
    hosts.x86_64-linux.onyx.users.verz = {};

    aspects.onyx = {
      includes = with den.aspects; [
        greetd

        kanata
        networkmanager

        ephemeral.btrfs

        plymouth
        lanzaboote
      ];

      provides.to-users.homeManager.programs.niri.settings.outputs."eDP-1" = {
        scale = 1.2;

        mode = {
          width = 1920;
          height = 1080;
          refresh = 144.003;
        };
      };

      nixos = {
        hardware.facter.reportPath = ./hardware.json;
        system.stateVersion = "26.11";
      };
    };
  };
}

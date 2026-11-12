{den, ...}: {
  den.aspects.verz = {
    includes = with den; [
      aspects.zen
      aspects.foot
      aspects.zed
      aspects.niri
      aspects.cursor

      aspects.jujutsu
      aspects.git
      aspects.direnv
      aspects.eza
      aspects.bat
      aspects.nh

      aspects.starship
      aspects.fish

      batteries.primary-user
      batteries.define-user
    ];

    user = {
      uid = 1000;
      initialPassword = "verz";
    };

    provides.to-hosts.nixos.nix.settings.trusted-users = ["verz"];

    homeManager = {
      programs = let
        identity = {
          name = "verzyo";
          email = "279150665+verzyo@users.noreply.github.com";
        };
      in {
        git.settings.user = identity;
        jujutsu.settings.user = identity;

        nh.flake = "/home/verz/systems";
      };

      home.stateVersion = "26.11";
    };
  };
}

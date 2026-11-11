{den, ...}: {
  den.aspects.verz = {
    includes = with den; [
      aspects.starship
      aspects.fish

      aspects.foot
      aspects.niri

      batteries.primary-user
      batteries.define-user
    ];

    user = {
      uid = 1000;
      initialPassword = "verz";
    };

    provides.to-hosts.nixos.nix.settings.trusted-users = ["verz"];

    homeManager.home.stateVersion = "26.11";
  };
}

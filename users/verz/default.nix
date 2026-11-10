{den, ...}: {
  den.aspects.verz = {
    includes = with den.batteries; [
      primary-user
      define-user
    ];

    user = {
      uid = 1000;
      initialPassword = "verz";
    };

    provides.to-hosts.nixos.nix.settings.trusted-users = ["verz"];

    homeManager.home.stateVersion = "26.11";
  };
}

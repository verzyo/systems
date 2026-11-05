{config, ...}: {
  nixos.modules.verz = {pkgs, ...}: {
    imports = with config.nixos.modules; [home-manager fish];

    users.users.verz = {
      isNormalUser = true;
      uid = 1000;

      extraGroups = ["wheel"];
      initialPassword = "verz";

      shell = pkgs.fish;
    };

    home-manager.users.verz.imports = [config.home.modules.verz];
  };

  home.modules.verz.imports = with config.home.modules; [
    fish
  ];
}

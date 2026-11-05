{
  inputs,
  lib,
  config,
  ...
}: {
  nixos.modules.home-manager = {pkgs, ...}: {
    imports = [inputs.home-manager.nixosModules.default];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      startAsUserService = true;
      backupCommand = lib.getExe pkgs.trash-cli;

      sharedModules = [
        config.home.modules.base
        ({osConfig, ...}: {
          home.stateVersion = lib.mkDefault osConfig.system.stateVersion;
        })
      ];
    };
  };

  home.modules.home-manager = {
    news.display = "silent";
    manual.manpages.enable = false;

    xdg.enable = true;
    home.preferXdgDirectories = true;
  };
}

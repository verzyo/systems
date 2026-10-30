{
  inputs,
  lib,
  ...
}: {
  nixos.modules.base = {pkgs, ...}: {
    imports = [inputs.home-manager.nixosModules.default];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      startAsUserService = true;
      backupCommand = lib.getExe pkgs.trash-cli;

      sharedModules = [
        ({osConfig, ...}: {
          home.stateVersion = lib.mkDefault osConfig.system.stateVersion;
        })
      ];
    };
  };
}

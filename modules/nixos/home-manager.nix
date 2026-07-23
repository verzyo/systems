{
  inputs,
  lib,
  config,
  ...
}: {
  imports = [inputs.home-manager.nixosModules.home-manager];

  config = lib.mkIf config.modules.home-manager.enable {
    home-manager = {
      extraSpecialArgs = {inherit inputs;};

      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };

  options.modules.home-manager.enable = lib.mkEnableOption "home-manager module";
}

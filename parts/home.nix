{
  inputs,
  config,
  lib,
  ...
}: {
  imports = [inputs.home-manager.flakeModules.home-manager];

  options.home = {
    modules = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.deferredModule;
      default = {};
      apply = lib.mapAttrs (name: module: {
        _class = "homeManager";
        _file = "home.modules.${name}";
        key = "home.modules.${name}";
        imports = [module];
      });
      description = "Home Manager modules, one per feature, imported by users and hosts.";
    };

    configurations = lib.mkOption {
      type = lib.types.lazyAttrsOf (lib.types.submodule {
        options = {
          system = lib.mkOption {
            type = lib.types.str;
            description = "Platform of the machine the home runs on.";
          };

          module = lib.mkOption {
            type = lib.types.deferredModule;
            description = "The home's Home Manager module.";
          };
        };
      });
      default = {};
      description = "Standalone homes (user@host), instantiated into homeConfigurations.";
    };
  };

  config.flake.homeConfigurations =
    lib.mapAttrs (
      _: home:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages.${home.system};
          modules = [home.module];
        }
    )
    config.home.configurations;
}

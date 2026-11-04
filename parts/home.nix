{
  inputs,
  config,
  lib,
  ...
}: {
  imports = [
    inputs.home-manager.flakeModules.default
    (inputs.import-tree [
      ../users
      ../modules
    ])
  ];

  config.flake.homeConfigurations =
    lib.mapAttrs (
      _: home:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages.${home.system};
          modules = [home.module];
        }
    )
    config.home.configurations;

  options.home = {
    modules = lib.mkOption {
      description = "Home Manager modules, one per feature, imported by users and hosts.";

      default = {};
      type = lib.types.lazyAttrsOf lib.types.deferredModule;

      apply = lib.mapAttrs (name: module: {
        _class = "homeManager";
        _file = "home.modules.${name}";
        key = "home.modules.${name}";
        imports = [module];
      });
    };

    configurations = lib.mkOption {
      description = "Standalone homes (user@host), instantiated into homeConfigurations.";

      default = {};
      type = lib.types.lazyAttrsOf (lib.types.submodule {
        options = {
          system = lib.mkOption {
            description = "Platform of the machine the home runs on.";
            type = lib.types.str;
          };

          module = lib.mkOption {
            description = "The home's Home Manager module.";
            type = lib.types.deferredModule;
          };
        };
      });
    };
  };
}

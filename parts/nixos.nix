{
  inputs,
  config,
  lib,
  ...
}: {
  imports = [
    (inputs.import-tree [
      ../hosts
      ../users
      ../modules
    ])
  ];

  config.flake.nixosConfigurations =
    lib.mapAttrs (
      name: host:
        inputs.nixpkgs.lib.nixosSystem {
          modules = [
            {
              networking.hostName = lib.mkDefault name;
              system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
            }
            config.nixos.modules.base
            host.module
          ];
        }
    )
    config.nixos.configurations;

  options.nixos = {
    modules = lib.mkOption {
      description = "NixOS modules, one per feature, imported by hosts.";

      default = {};
      type = lib.types.lazyAttrsOf lib.types.deferredModule;

      apply = lib.mapAttrs (name: module: {
        _class = "nixos";
        _file = "nixos.modules.${name}";
        key = "nixos.modules.${name}";
        imports = [module];
      });
    };

    configurations = lib.mkOption {
      description = "NixOS hosts, instantiated into nixosConfigurations.";

      default = {};
      type = lib.types.lazyAttrsOf (lib.types.submodule {
        options.module = lib.mkOption {
          description = "The host's NixOS module.";
          type = lib.types.deferredModule;
        };
      });
    };
  };
}

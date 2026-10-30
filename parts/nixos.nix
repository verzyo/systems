{
  inputs,
  config,
  lib,
  ...
}: {
  options.nixos = {
    modules = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.deferredModule;
      default = {};
      apply = lib.mapAttrs (name: module: {
        _class = "nixos";
        _file = "nixos.modules.${name}";
        key = "nixos.modules.${name}";
        imports = [module];
      });
      description = "NixOS modules, one per feature, imported by hosts.";
    };

    configurations = lib.mkOption {
      type = lib.types.lazyAttrsOf (lib.types.submodule {
        options.module = lib.mkOption {
          type = lib.types.deferredModule;
          description = "The host's NixOS module.";
        };
      });
      default = {};
      description = "NixOS hosts, instantiated into nixosConfigurations.";
    };
  };

  config.flake.nixosConfigurations =
    lib.mapAttrs (
      name: host:
        inputs.nixpkgs.lib.nixosSystem {
          modules = [
            config.nixos.modules.base
            {networking.hostName = lib.mkDefault name;}
            host.module
          ];
        }
    )
    config.nixos.configurations;
}

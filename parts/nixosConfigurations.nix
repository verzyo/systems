{
  inputs,
  lib,
  self,
  ...
}: let
  hostnames = builtins.attrNames (
    lib.filterAttrs (_: type: type == "directory")
    (builtins.readDir "${self}/hosts")
  );
in {
  flake.nixosConfigurations = lib.genAttrs hostnames (
    hostname:
      inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs self;};

        modules = [
          "${self}/hosts/${hostname}"
          (inputs.import-tree "${self}/modules/nixos")
        ];
      }
  );
}

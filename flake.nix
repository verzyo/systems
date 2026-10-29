{
  inputs = {
    import-tree.url = "github:denful/import-tree";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        (inputs.import-tree (builtins.filter builtins.pathExists [
          ./parts
          ./hosts
          ./users
          ./modules
        ]))
      ];
    };
}

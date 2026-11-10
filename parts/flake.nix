{inputs, ...}: {
  imports = [inputs.flake-file.flakeModules.default];

  flake-file = {
    auto-follow.enable = true;

    inputs = {
      flake-file.url = "github:denful/flake-file";
      import-tree.url = "github:denful/import-tree";

      flake-parts = {
        url = "github:hercules-ci/flake-parts";
        inputs.nixpkgs-lib.follows = "nixpkgs";
      };

      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    };
  };
}

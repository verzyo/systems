{
  inputs = {
    # USER #
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # SYSTEM #
    preservation.url = "github:nix-community/preservation";

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        pre-commit.follows = "";
      };
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate = {
      url = "github:DeterminateSystems/determinate";
      inputs = {
        nix.inputs = {
          flake-parts.follows = "flake-parts";
          git-hooks-nix.follows = "";
          nixpkgs-23-11.follows = "";
          nixpkgs-regression.follows = "";
        };

        determinate-nixd-aarch64-darwin.follows = "";
        nixpkgs.follows = "nixpkgs";
      };
    };

    # FRAMEWORK #
    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    import-tree.url = "github:denful/import-tree";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # CORE #
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

# DO-NOT-EDIT. This file was auto-generated using github:denful/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  outputs = inputs: import ./outputs.nix inputs;

  nixConfig = {
    extra-substituters = ["https://install.determinate.systems" "https://niri-epireyn.cachix.org"];
    extra-trusted-public-keys = ["cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM=" "niri-epireyn.cachix.org-1:tlVyFN7CtsDT+ZcLPS+ekFWeT1X6X4OqvWqbBMyIzFA="];
  };

  inputs = {
    den = {url = "github:denful/den";};
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
      inputs = {
        nix.inputs = {
          flake-parts.follows = "flake-parts";
          git-hooks-nix.follows = "";
          nixpkgs-23-11.follows = "";
          nixpkgs-regression.follows = "";
        };
        nixpkgs.follows = "nixpkgs";
      };
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-file = {url = "github:denful/flake-file";};
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    import-tree = {url = "github:denful/import-tree";};
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        pre-commit.follows = "";
      };
    };
    niri = {url = "github:epireyn/niri-flake";};
    nixpkgs = {url = "github:NixOS/nixpkgs/nixos-unstable";};
    preservation = {url = "github:nix-community/preservation";};
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}

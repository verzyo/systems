{inputs, ...}: {
  imports = [inputs.treefmt.flakeModule];

  perSystem.treefmt = {
    projectRootFile = "flake.nix";

    programs = {
      alejandra.enable = true; # .nix
      prettier = {
        enable = true;
        includes = ["*.json"];
      };
    };
  };
}

{inputs, ...}: {
  imports = [inputs.treefmt.flakeModule];

  perSystem = _: {
    treefmt.config = {
      projectRootFile = "flake.nix";

      programs = {
        alejandra.enable = true;

        statix.enable = true;
        deadnix.enable = true;

        prettier = {
          enable = true;
          includes = ["*.json" "*.md"];
        };
      };
    };
  };
}

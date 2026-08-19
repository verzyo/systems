{inputs, ...}: {
  imports = [inputs.treefmt.flakeModule];

  perSystem = _: {
    treefmt.config = {
      projectRootFile = "flake.nix";

      programs = {
        prettier = {
          enable = true;
          includes = ["*.json" "*.yaml" "*.md"];
        };

        shfmt.enable = true;

        statix.enable = true;
        deadnix.enable = true;

        alejandra.enable = true;
      };
    };
  };
}

{inputs, ...}: {
  imports = [inputs.treefmt.flakeModule];

  perSystem.treefmt.programs = {
    # nix
    alejandra.enable = true;
    statix.enable = true;
    deadnix.enable = true;

    # json
    biome = {
      enable = true;
      includes = ["*.json"];
    };
  };
}

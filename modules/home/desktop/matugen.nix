{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.desktop.matugen.enable {
    home.packages = [pkgs.matugen];

    xdg.configFile."matugen/config.toml".source = (pkgs.formats.toml {}).generate "matugen-config.toml" {
      config = {};

      templates = let
        templates = "${inputs.dankmaterialshell}/quickshell/matugen/templates";
        configHome = config.xdg.configHome;
      in {
        niri = {
          input_path = "${templates}/niri-colors.kdl";
          output_path = "${configHome}/niri/colors.kdl";
        };
      };
    };
  };

  options.modules.desktop.matugen.enable = lib.mkEnableOption "matugen module";
}

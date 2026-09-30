{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  templateFile = "niri-colors.kdl";
  stagedTemplate = "${config.xdg.configHome}/matugen/templates/${templateFile}";
  colorsFile = "${config.xdg.configHome}/niri/colors.kdl";
in {
  config = lib.mkIf config.modules.desktop.matugen.enable {
    home.packages = [pkgs.matugen];

    xdg.configFile."matugen/templates/niri-colors.kdl".source = "${inputs.dankmaterialshell}/quickshell/matugen/templates/${templateFile}";

    xdg.configFile."matugen/config.toml".source = (pkgs.formats.toml {}).generate "matugen-config.toml" {
      config = {};

      templates.niri = {
        input_path = stagedTemplate;
        output_path = colorsFile;
      };
    };
  };

  options.modules.desktop.matugen.enable = lib.mkEnableOption "matugen module";
}

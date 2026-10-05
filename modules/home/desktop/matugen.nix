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
        dmsTemplates = "${inputs.dankmaterialshell}/quickshell/matugen/templates";
        meowtugenTemplates = "${inputs.meowtugen}/templates";

        configHome = config.xdg.configHome;
      in {
        foot_colors.input_path = "${meowtugenTemplates}/foot/colors.ini";

        foot = {
          input_path = "${meowtugenTemplates}/foot/foot.ini";
          output_path = "${configHome}/foot/colors.ini";
        };

        niri = {
          input_path = "${dmsTemplates}/niri-colors.kdl";
          output_path = "${configHome}/niri/colors.kdl";
        };
      };
    };
  };

  options.modules.desktop.matugen.enable = lib.mkEnableOption "matugen module";
}

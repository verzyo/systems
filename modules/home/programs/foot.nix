{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.programs.foot.enable {
    programs.foot = {
      enable = true;

      settings.main.include = lib.mkIf config.modules.desktop.matugen.enable [
        "${config.xdg.configHome}/foot/colors.ini"
      ];
    };
  };

  options.modules.programs.foot.enable = lib.mkEnableOption "foot module";
}

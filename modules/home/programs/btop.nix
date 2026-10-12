{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.programs.btop.enable {
    programs.btop = {
      enable = true;
      settings = lib.mkIf config.modules.desktop.meowtugen.enable {
        color_theme = "meowtugen";
      };
    };
  };

  options.modules.programs.btop.enable = lib.mkEnableOption "btop module";
}

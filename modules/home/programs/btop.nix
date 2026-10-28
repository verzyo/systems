{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.programs.btop.enable {
    programs.btop = {
      enable = true;
      settings = lib.mkIf config.modules.desktop.m3owtugen.enable {
        color_theme = "m3owtugen";
      };
    };
  };

  options.modules.programs.btop.enable = lib.mkEnableOption "btop module";
}

{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.desktop.cursor.enable {
    home.pointerCursor = {
      enable = true;

      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
    };

    programs.niri.settings = lib.mkIf config.modules.desktop.niri.enable {
      cursor.size = 20;
    };
  };

  options.modules.desktop.cursor.enable = lib.mkEnableOption "cursor module";
}

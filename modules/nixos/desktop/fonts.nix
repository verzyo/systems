{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.desktop.fonts.enable {
    fonts.packages = with pkgs; [
      nerd-fonts.symbols-only
    ];
  };

  options.modules.desktop.fonts.enable = lib.mkEnableOption "fonts module";
}

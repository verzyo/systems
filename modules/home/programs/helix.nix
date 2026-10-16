{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.programs.helix.enable {
    programs.helix = {
      enable = true;
      package = pkgs.evil-helix;

      settings.theme = "base16_default";
    };
  };

  options.modules.programs.helix.enable = lib.mkEnableOption "helix module";
}

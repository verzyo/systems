{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.shell.starship.enable {
    programs.starship.enable = true;
  };

  options.modules.shell.starship.enable = lib.mkEnableOption "starship module";
}

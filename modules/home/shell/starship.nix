{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.shell.starship.enable {
    programs.starship = {
      enable = true;
      settings.scan_timeout = 100;
    };
  };

  options.modules.shell.starship.enable = lib.mkEnableOption "starship module";
}

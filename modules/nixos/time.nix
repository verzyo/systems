{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.time.enable {
    time.timeZone = "Europe/Prague";
  };

  options.modules.time.enable = lib.mkEnableOption "time module";
}

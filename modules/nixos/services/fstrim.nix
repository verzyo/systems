{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.services.fstrim.enable {
    services.fstrim.enable = true;
  };

  options.modules.services.fstrim.enable = lib.mkEnableOption "fstrim module";
}

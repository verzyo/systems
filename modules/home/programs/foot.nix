{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.programs.foot.enable {
    programs.foot.enable = true;
  };

  options.modules.programs.foot.enable = lib.mkEnableOption "foot module";
}

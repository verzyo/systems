{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.programs.foot.enable {
    programs.foot = {
      enable = true;

      server = {
        enable = true;
        systemdTarget = "niri.service";
      };
    };
  };

  options.modules.programs.foot.enable = lib.mkEnableOption "foot module";
}

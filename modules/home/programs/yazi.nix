{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.programs.yazi.enable {
    programs.yazi = {
      enable = true;
    };
  };

  options.modules.programs.yazi.enable = lib.mkEnableOption "yazi module";
}

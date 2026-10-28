{
  inputs,
  lib,
  config,
  ...
}: {
  imports = [inputs.m3owtugen.homeModules.m3owtugen];

  config = lib.mkIf config.modules.desktop.m3owtugen.enable {
    programs.m3owtugen.enable = true;
  };

  options.modules.desktop.m3owtugen.enable = lib.mkEnableOption "m3owtugen module";
}

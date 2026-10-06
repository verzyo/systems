{
  inputs,
  lib,
  config,
  ...
}: {
  imports = [inputs.meowtugen.homeModules.meowtugen];

  config = lib.mkIf config.modules.desktop.meowtugen.enable {
    programs.meowtugen.enable = true;
  };

  options.modules.desktop.meowtugen.enable = lib.mkEnableOption "meowtugen module";
}

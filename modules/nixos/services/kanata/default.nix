{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.services.kanata.enable {
    services.kanata = {
      enable = true;
      keyboards.all.configFile = ./config.kbd;
    };
  };

  options.modules.services.kanata.enable = lib.mkEnableOption "kanata module";
}

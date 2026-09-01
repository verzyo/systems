{
  inputs,
  lib,
  config,
  ...
}: {
  imports = [inputs.cliproxyapi.homeModules.cliproxyapi];

  config = lib.mkIf config.modules.services.cliproxyapi.enable {
    services.cliproxyapi = {
      enable = true;

      settings = {
        host = "localhost";
        port = 8317;

        remote-management = {
          secret-key = "$2a$10$Haj8Wg1302Kl8A8rFRlLtOdmM03e1CwO.oxXFJHQ1SExn7wygm78.";
          disable-control-panel = false;
        };
      };
    };
  };

  options.modules.services.cliproxyapi.enable = lib.mkEnableOption "cliproxyapi module";
}

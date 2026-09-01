{
  inputs,
  lib,
  config,
  osConfig,
  ...
}: {
  imports = [inputs.cliproxyapi.homeModules.cliproxyapi];

  config = lib.mkIf config.modules.services.cliproxyapi.enable {
    services.cliproxyapi = {
      enable = true;
      managementPasswordFile = lib.mkIf osConfig.modules.sops.enable osConfig.sops.secrets."management_key".path;

      settings = {
        host = "localhost";
        port = 8317;

        remote-management.disable-control-panel = false;
      };
    };
  };

  options.modules.services.cliproxyapi.enable = lib.mkEnableOption "cliproxyapi module";
}

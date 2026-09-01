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
      managementPasswordFile = lib.mkIf osConfig.modules.sops.enable osConfig.sops.secrets."management_pass".path;

      plugins = [
        "antigravity-coding-filter"
        "antigravity-priority"
        "quota-activation"
        "privacyfilter"
        "cpa-apply-patch"
        "grok-manager"
      ];

      settings = let
        secret = key: config.lib.cliproxyapi.injectSecret osConfig.sops.secrets.${key}.path;
      in {
        host = "localhost";
        port = 8317;

        plugins = {
          enabled = true;

          configs = {
            "antigravity-coding-filter".enabled = true;
            "antigravity-priority".enabled = true;
            "cpa-apply-patch".enabled = true;
            "privacyfilter".enabled = true;
            "quota-activation".enabled = true;
            "grok-manager".enabled = true;
          };
        };

        api-keys = [(secret "proxy_key")];
        remote-management.disable-control-panel = false;
      };
    };
  };

  options.modules.services.cliproxyapi.enable = lib.mkEnableOption "cliproxyapi module";
}

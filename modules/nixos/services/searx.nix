{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.services.searx.enable {
    services.searx = {
      enable = true;
      settings = {
        server = {
          port = 8888;
          bind_address = "127.0.0.1";
          secret_key = "hermes-local-searxng-secret-key";
        };
        search = {
          formats = ["html" "json"];
        };
      };
    };
  };

  options.modules.services.searx.enable = lib.mkEnableOption "searxng meta search engine module";
}

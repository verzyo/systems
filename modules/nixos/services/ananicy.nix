{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.services.ananicy.enable {
    services.ananicy = {
      enable = true;

      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };
  };

  options.modules.services.ananicy.enable = lib.mkEnableOption "ananicy module";
}

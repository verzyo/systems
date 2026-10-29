{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.perlless.enable {
    services.userborn = {
      enable = true;

      # /etc is wiped on boot, keep the uid/gid allocation on persisted state
      passwordFilesLocation = lib.mkIf config.modules.preservation.enable "/var/lib/nixos";
    };

    system = {
      etc.overlay.enable = true;
      nixos-init.enable = true;

      tools.nixos-generate-config.enable = false;
    };

    documentation = {
      info.enable = false;
      nixos.enable = false;
    };

    environment.defaultPackages = [];
  };

  options.modules.perlless.enable = lib.mkEnableOption "perlless module";
}

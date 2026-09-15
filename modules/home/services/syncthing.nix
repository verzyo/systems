{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.services.syncthing.enable {
    services.syncthing = {
      enable = true;
      guiAddress = "127.0.0.1:8384";

      overrideDevices = false;
      overrideFolders = false;

      settings = {
        devices = {
          phone.id = "NGFPYL7-54QU6DL-F42VMUO-MTQVXFF-B5WDXUS-AN2ENVB-M4YKHHX-PWIODAL";
        };

        folders.notes = {
          id = "notes";
          label = "notes";

          path = "~/notes";
          devices = ["phone"];

          versioning = {
            type = "staggered";

            params = {
              cleanInterval = "86400"; # per day
              maxAge = "2592000"; # 30 days
            };
          };
        };

        options.urAccepted = -1;
      };
    };
  };

  options.modules.services.syncthing.enable = lib.mkEnableOption "syncthing module";
}

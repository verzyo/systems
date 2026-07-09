{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.users.verz.enable {
    users.users.verz = {
      extraGroups =
        [
          "video"
          "audio"

          "wheel"
        ]
        ++ lib.optional config.networking.networkmanager.enable "networkmanager";

      initialPassword = "verz";
      isNormalUser = true;
    };
  };

  options.modules.users.verz.enable = lib.mkEnableOption "verz user account";
}

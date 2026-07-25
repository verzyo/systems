{
  inputs,
  pkgs,
  lib,
  self,
  config,
  ...
}: {
  config = lib.mkIf config.modules.users.verz.enable {
    programs.fish.enable = true;

    users.users.verz = {
      shell = pkgs.fish;

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

    home-manager.users.verz = lib.mkIf config.modules.home-manager.enable {
      imports = [
        "${self}/users/verz"
        (inputs.import-tree "${self}/modules/home")
      ];
    };
  };

  options.modules.users.verz.enable = lib.mkEnableOption "verz user account";
}

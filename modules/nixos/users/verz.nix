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

    nix.settings.trusted-users = ["verz"];

    users.users.verz = {
      shell = pkgs.fish;

      extraGroups =
        [
          "video"
          "audio"

          "wheel"
        ]
        ++ lib.optional config.networking.networkmanager.enable "networkmanager";

      initialPassword = lib.mkIf (!config.modules.sops.hasSecret "users/verz") "verz";
      hashedPasswordFile = lib.mkIf (config.modules.sops.hasSecret "users/verz") config.sops.secrets."users/verz".path;

      isNormalUser = true;
    };

    sops.secrets = lib.mkMerge [
      (lib.mkIf (config.modules.sops.hasSecret "users/verz") {
        "users/verz".neededForUsers = true;
      })
      (lib.mkIf config.modules.sops.enable {
        "management_pass" = {
          sopsFile = "${self}/secrets/cliproxyapi.json";
          owner = "verz";
        };
        "proxy_key".sopsFile = "${self}/secrets/cliproxyapi.json";

        "oauth/antigravity/paid1/email" = {
          sopsFile = "${self}/secrets/cliproxyapi.json";
          owner = "verz";
        };
        "oauth/antigravity/paid1/refresh_token" = {
          sopsFile = "${self}/secrets/cliproxyapi.json";
          owner = "verz";
        };
        "oauth/antigravity/free1/email" = {
          sopsFile = "${self}/secrets/cliproxyapi.json";
          owner = "verz";
        };
        "oauth/antigravity/free1/refresh_token" = {
          sopsFile = "${self}/secrets/cliproxyapi.json";
          owner = "verz";
        };
        "oauth/antigravity/free2/email" = {
          sopsFile = "${self}/secrets/cliproxyapi.json";
          owner = "verz";
        };
        "oauth/antigravity/free2/refresh_token" = {
          sopsFile = "${self}/secrets/cliproxyapi.json";
          owner = "verz";
        };
        "oauth/antigravity/free3/email" = {
          sopsFile = "${self}/secrets/cliproxyapi.json";
          owner = "verz";
        };
        "oauth/antigravity/free3/refresh_token" = {
          sopsFile = "${self}/secrets/cliproxyapi.json";
          owner = "verz";
        };
        "oauth/antigravity/free4/email" = {
          sopsFile = "${self}/secrets/cliproxyapi.json";
          owner = "verz";
        };
        "oauth/antigravity/free4/refresh_token" = {
          sopsFile = "${self}/secrets/cliproxyapi.json";
          owner = "verz";
        };
        "oauth/antigravity/free5/email" = {
          sopsFile = "${self}/secrets/cliproxyapi.json";
          owner = "verz";
        };
        "oauth/antigravity/free5/refresh_token" = {
          sopsFile = "${self}/secrets/cliproxyapi.json";
          owner = "verz";
        };
      })
    ];

    home-manager.users.verz = lib.mkIf config.modules.home-manager.enable {
      imports = [
        "${self}/users/verz"
        (inputs.import-tree "${self}/modules/home")
      ];
    };
  };

  options.modules.users.verz.enable = lib.mkEnableOption "verz user account";
}

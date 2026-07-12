{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [inputs.niri.nixosModules.niri];

  config = lib.mkIf config.modules.desktop.niri.enable {
    programs.niri = {
      enable = true;
      package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
    };

    services.gnome.gnome-keyring.enable = lib.mkForce false;
    systemd.user.services.niri-flake-polkit.enable = false;

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    niri-flake.cache.enable = false;

    nix.settings = {
      substituters = ["https://niri.cachix.org/"];
      trusted-public-keys = ["niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="];
    };
  };

  options.modules.desktop.niri.enable = lib.mkEnableOption "niri module";
}

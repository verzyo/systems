{inputs, ...}: let
  cache = {
    substituter = "https://niri-epireyn.cachix.org";
    key = "niri-epireyn.cachix.org-1:tlVyFN7CtsDT+ZcLPS+ekFWeT1X6X4OqvWqbBMyIzFA=";
  };
in {
  flake-file = {
    inputs.niri = {
      url = "github:epireyn/niri-flake";
      inputs.nixpkgs.autoFollow = false;
    };

    nixConfig = {
      extra-substituters = [cache.substituter];
      extra-trusted-public-keys = [cache.key];
    };
  };

  den.aspects.niri = {
    nixos = {
      config,
      pkgs,
      lib,
      ...
    }: {
      imports = [inputs.niri.nixosModules.niri];

      programs.niri = {
        enable = true;
        package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
      };

      services.greetd.settings.initial_session = lib.mkIf config.services.displayManager.autoLogin.enable {
        command = lib.mkDefault "${lib.getExe' pkgs.systemd "systemd-cat"} -t niri-session ${lib.getExe' config.programs.niri.package "niri-session"}";
      };

      niri-flake.cache.enable = false;
      nix.settings = {
        substituters = [cache.substituter];
        trusted-public-keys = [cache.key];
      };

      services.gnome.gnome-keyring.enable = lib.mkForce false;
      systemd.user.services.niri-flake-polkit.enable = false;
      xdg.portal.enable = lib.mkForce false;
    };
  };
}

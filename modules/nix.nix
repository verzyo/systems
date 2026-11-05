{
  inputs,
  lib,
  ...
}: let
  common = {
    gc = {
      automatic = true;
      persistent = true;

      dates = "weekly";
      options = lib.mkDefault "--delete-older-than 7d";
    };

    registry.nixpkgs.flake = inputs.nixpkgs;

    settings = {
      use-xdg-base-directories = true;
      flake-registry = "";
    };
  };
in {
  nixos.modules.nix = {
    imports = [inputs.determinate.nixosModules.default];

    nix = lib.mkMerge [
      common
      {
        optimise = {
          automatic = true;
          persistent = true;

          dates = ["weekly"];
        };

        settings = {
          download-buffer-size = lib.mkDefault 268435456; # 256 MiB

          substituters = ["https://install.determinate.systems"];
          trusted-public-keys = ["cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="];
        };

        channel.enable = false;
      }
    ];

    systemd.services.nix-daemon.serviceConfig = {
      CPUWeight = lib.mkDefault 20;
      IOWeight = lib.mkDefault 20;
    };

    nixpkgs.config.allowUnfree = true;

    programs = {
      git.enable = true;
      command-not-found.enable = false;
    };
  };

  home.modules.nix = {
    pkgs,
    config,
    ...
  }:
    lib.mkIf (!config.submoduleSupport.enable) {
      nix = lib.mkMerge [
        common
        {package = lib.mkDefault pkgs.nix;}
      ];
    };
}

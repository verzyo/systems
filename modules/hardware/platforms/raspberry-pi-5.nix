{inputs, ...}: let
  cache = {
    substituter = "https://nixos-raspberrypi.cachix.org";
    key = "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI=";
  };
in {
  flake-file = {
    inputs.raspberry-pi = {
      url = "github:nvmd/nixos-raspberrypi/main";
      inputs.nixpkgs.autoFollow = false;
    };

    nixConfig = {
      extra-substituters = [cache.substituter];
      extra-trusted-public-keys = [cache.key];
    };
  };

  den.aspects.raspberry-pi-5.nixos = {
    pkgs,
    lib,
    ...
  }: {
    imports = with inputs; [
      raspberry-pi.lib.inject-overlays
      raspberry-pi.nixosModules.raspberry-pi-5.base
    ];
    _module.args.nixos-raspberrypi = inputs.raspberry-pi;

    boot.loader.raspberry-pi.bootloader = "kernel";

    # the cached rpi kernel comes from nixos-26.05 and lacks attributes our 26.11
    # nixpkgs reads. adding them keeps the store path, so it still hits the cache
    boot.kernelPackages = lib.mkForce (
      inputs.raspberry-pi.packages.${pkgs.stdenv.hostPlatform.system}.linuxPackages_rpi5.extend (_: prev: {
        kernel = prev.kernel.overrideAttrs (old: {
          passthru =
            old.passthru
            // {
              buildDTBs = true;
              target = "Image"; # aarch64 kernel image
            };
        });
      })
    );

    nix.settings = {
      substituters = [cache.substituter];
      trusted-public-keys = [cache.key];
    };
  };
}

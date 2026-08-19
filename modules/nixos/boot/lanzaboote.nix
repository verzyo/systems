{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.boot.lanzaboote;
in {
  imports = [inputs.lanzaboote.nixosModules.lanzaboote];

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.sbctl];

    boot.loader.efi.canTouchEfiVariables = true;

    boot.lanzaboote = {
      enable = true;
      autoGenerateKeys.enable = true;

      autoEnrollKeys = {
        enable = true;
        autoReboot = true;
      };

      pkiBundle = "/var/lib/sbctl";
      configurationLimit = 8;

      measuredBoot = {
        enable = true;
        pcrs = [0 4 7];
        pcrlockPolicy = "/var/lib/pcrlock.d/pcrlock.json";

        autoCryptenroll = lib.mkIf (config.boot.initrd.luks.devices != {}) {
          enable = true;
          inherit ((lib.head (lib.attrValues config.boot.initrd.luks.devices))) device;
        };
      };
    };

    preservation.preserveAt."/${config.modules.preservation.preservedSubvolume}" = lib.mkIf config.modules.preservation.enable {
      directories = [
        "/var/lib/sbctl"
        "/var/lib/pcrlock.d"
        "/var/lib/auto-cryptenroll"
      ];
    };
  };

  options.modules.boot.lanzaboote.enable = lib.mkEnableOption "lanzaboote secure boot";
}

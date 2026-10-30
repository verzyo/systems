{inputs, ...}: {
  nixos.modules.lanzaboote = {
    pkgs,
    lib,
    config,
    ...
  }: let
    luks = lib.attrValues config.boot.initrd.luks.devices;
    cryptenroll = config.boot.lanzaboote.measuredBoot.autoCryptenroll;
  in {
    imports = [inputs.lanzaboote.nixosModules.default];

    environment.systemPackages = [pkgs.sbctl];

    boot = {
      loader = {
        timeout = 0;
        efi.canTouchEfiVariables = true;
      };

      lanzaboote = {
        enable = true;

        autoGenerateKeys.enable = true;
        settings.console-mode = "max";

        autoEnrollKeys = {
          enable = true;
          autoReboot = true;
        };

        pkiBundle = "/var/lib/sbctl";
        configurationLimit = 4;

        measuredBoot = {
          enable = true;

          pcrs = [0 4 7];
          pcrlockPolicy = "/var/lib/pcrlock.d/pcrlock.json";

          autoCryptenroll = {
            enable = luks != [];
            device = lib.mkIf (lib.length luks == 1) (lib.mkDefault (lib.head luks).device);
          };
        };
      };
    };

    assertions = [
      {
        assertion = cryptenroll.enable -> cryptenroll.device != null;
        message = ''
          ${config.networking.hostName}: lanzaboote can't pick a LUKS device for autoCryptenroll, found ${toString (lib.length luks)}:
          ${lib.concatMapStringsSep "\n" (d: "    ${d.name}: ${d.device}") luks}
            Set the one holding your root filesystem, e.g.
              boot.lanzaboote.measuredBoot.autoCryptenroll.device = "${(lib.head luks).device}";
        '';
      }
    ];
  };
}

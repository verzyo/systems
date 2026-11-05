{inputs, ...}: {
  nixos.modules.lanzaboote = {
    pkgs,
    lib,
    config,
    ...
  }: let
    # volumes the host unlocks with the TPM, via crypttabExtraOpts = ["tpm2-device=..."]
    tpm = lib.filter (luks: lib.any (lib.hasPrefix "tpm2-device=") luks.crypttabExtraOpts) (lib.attrValues config.boot.initrd.luks.devices);
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
          enable = tpm != [];

          pcrs = [0 4 7];
          pcrlockPolicy = "/var/lib/pcrlock.d/pcrlock.json";

          autoCryptenroll = {
            enable = tpm != [];
            device = lib.mkIf (lib.length tpm == 1) (lib.mkDefault (lib.head tpm).device);
          };
        };
      };
    };

    assertions = [
      {
        assertion = cryptenroll.enable -> cryptenroll.device != null;
        message = ''
          ${config.networking.hostName}: lanzaboote can't pick a LUKS device for autoCryptenroll, found ${toString (lib.length tpm)} with tpm2-device in crypttabExtraOpts:
          ${lib.concatMapStringsSep "\n" (luks: "    ${luks.name}: ${luks.device}") tpm}
            Set the one to enroll, e.g.
              boot.lanzaboote.measuredBoot.autoCryptenroll.device = "/dev/disk/by-partlabel/...";
        '';
      }
    ];
  };

  nixos.modules.ephemeral = {
    config,
    lib,
    ...
  }:
    lib.mkIf (config.boot.lanzaboote.enable or false) {
      preservation.preserveAt.state.directories = lib.unique [
        {
          directory = config.boot.lanzaboote.pkiBundle;
          mode = "0700";
        }
        config.boot.lanzaboote.measuredBoot.pcrlockDirectory
        (dirOf config.boot.lanzaboote.measuredBoot.pcrlockPolicy)
        "/var/lib/auto-cryptenroll"
      ];
    };
}

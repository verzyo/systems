{
  inputs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.sops;

  secretsData =
    if cfg.enable
    then builtins.fromJSON (builtins.readFile cfg.secretsFile)
    else {};
in {
  imports = [inputs.sops.nixosModules.sops];

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      sops = {
        age.sshKeyPaths = ["/${config.modules.preservation.preservedSubvolume}/etc/ssh/ssh_host_ed25519_key"];
        defaultSopsFile = cfg.secretsFile;
      };

      preservation = lib.mkIf config.modules.preservation.enable {
        preserveAt."/${config.modules.preservation.preservedSubvolume}".directories = [
          "/etc/ssh"
        ];
      };
    })
    {
      modules.sops.hasSecret = path: cfg.enable && lib.hasAttrByPath (lib.splitString "/" path) secretsData;
    }
  ];

  options.modules.sops = {
    enable = lib.mkEnableOption "sops module";

    secretsFile = lib.mkOption {
      type = lib.types.path;
      description = "The path to a host's secrets.json file";
    };

    hasSecret = lib.mkOption {
      type = lib.types.raw;
      internal = true;
      description = "Check if a key path exists in the secrets file";
    };
  };
}

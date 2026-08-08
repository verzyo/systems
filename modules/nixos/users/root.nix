{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.users.root.enable {
    users.users.root = {
      initialPassword = lib.mkIf (!config.modules.sops.hasSecret "users/root") "root";
      hashedPasswordFile = lib.mkIf (config.modules.sops.hasSecret "users/root") config.sops.secrets."users/root".path;
    };

    sops.secrets = lib.mkIf (config.modules.sops.hasSecret "users/root") {
      "users/root".neededForUsers = true;
    };

    preservation = lib.mkIf config.modules.preservation.enable {
      preserveAt."/${config.modules.preservation.preservedSubvolume}".directories = [
        "/root/.local/share/nix"
        "/root/.cache/nix"
      ];
    };
  };

  options.modules.users.root.enable = lib.mkEnableOption "root user account";
}

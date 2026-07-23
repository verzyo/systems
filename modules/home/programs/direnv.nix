{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.programs.direnv.enable {
    programs.direnv = {
      enable = true;

      silent = true;
      nix-direnv.enable = true;
    };
  };

  options.modules.programs.direnv.enable = lib.mkEnableOption "direnv module";
}

{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.programs.jujutsu.enable {
    programs.jujutsu = {
      enable = true;

      settings = {
        user = {
          name = "verzyo";
          email = "279150665+verzyo@users.noreply.github.com";
        };
      };
    };
  };

  options.modules.programs.jujutsu.enable = lib.mkEnableOption "jujutsu module";
}

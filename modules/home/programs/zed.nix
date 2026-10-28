{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.programs.zed.enable {
    programs.zed-editor = {
      enable = true;

      extensions = ["nix"];

      userSettings = {
        hour_format = "hour24";
        auto_update = false;

        vim_mode = true;
        relative_line_numbers = true;

        load_direnv = lib.mkIf config.modules.programs.direnv.enable "shell_hook";

        theme = lib.mkIf config.modules.desktop.m3owtugen.enable {
          mode = "dark";
          dark = "Meowtugen";
        };

        telemetry = {
          diagnostics = false;
          metrics = false;
        };
      };
    };
  };

  options.modules.programs.zed.enable = lib.mkEnableOption "zed module";
}

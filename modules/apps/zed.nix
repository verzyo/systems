{
  den.aspects.zed.homeManager = {
    lib,
    config,
    ...
  }: {
    programs.zed-editor = {
      enable = true;

      extensions = ["nix"];

      userSettings = {
        hour_format = "hour24";
        auto_update = false;

        vim_mode = true;
        relative_line_numbers = true;

        load_direnv = lib.mkIf config.programs.direnv.enable "shell_hook";

        telemetry = {
          diagnostics = false;
          metrics = false;
        };
      };
    };
  };
}

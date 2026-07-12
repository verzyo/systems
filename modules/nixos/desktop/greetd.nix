{
  lib,
  config,
  pkgs,
  ...
}: {
  config = lib.mkIf config.modules.desktop.greetd.enable {
    services.greetd = {
      enable = true;

      settings = {
        initial_session = lib.mkIf config.programs.niri.enable {
          command = "${config.programs.niri.package}/bin/niri-session";
          user = config.modules.desktop.greetd.autoLoginUser;
        };

        default_session = {
          command = "${pkgs.greetd}/bin/agreety --cmd '$SHELL --login'";
          user = "greeter";
        };
      };
    };
  };

  options.modules.desktop.greetd = {
    autoLoginUser = lib.mkOption {
      type = lib.types.str;
      description = "The user to automatically log into the window manager";
    };

    enable = lib.mkEnableOption "greetd module";
  };
}

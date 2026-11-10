{
  den.aspects.greetd.nixos = {
    config,
    pkgs,
    lib,
    ...
  }: let
    inherit (config.services.displayManager) autoLogin;
  in {
    assertions = [
      {
        assertion = autoLogin.enable -> config.services.greetd.settings.initial_session ? command;
        message = "${config.networking.hostName}: greetd autologin needs a session, set services.greetd.settings.initial_session.command";
      }
    ];

    services.greetd = {
      enable = true;
      useTextGreeter = true;

      settings.initial_session = lib.mkIf autoLogin.enable {
        inherit (autoLogin) user;
      };

      settings.default_session = {
        command = "${lib.getExe' pkgs.greetd "agreety"} --cmd '$SHELL --login'";
        user = "greeter";
      };
    };
  };
}

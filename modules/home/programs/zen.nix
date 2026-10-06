{
  inputs,
  lib,
  config,
  ...
}: {
  imports = [inputs.zen.homeModules.twilight];

  config = lib.mkMerge [
    (lib.mkIf config.modules.programs.zen.enable {
      programs.zen-browser = {
        enable = true;
        setAsDefaultBrowser = true;

        policies = {
          DontCheckDefaultBrowser = true;
          OverrideFirstRunPage = "";
        };

        profiles.default = {
          isDefault = true;
          sine.enable = true;

          settings = {
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            "zen.welcome-screen.seen" = true;
          };
        };
      };
    })

    (lib.mkIf (config.modules.programs.zen.enable && config.modules.desktop.meowtugen.enable) {
      programs.meowtugen.zen.withSine = true;
    })
  ];

  options.modules.programs.zen.enable = lib.mkEnableOption "zen browser module";
}

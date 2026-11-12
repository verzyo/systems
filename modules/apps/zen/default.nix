{inputs, ...}: {
  flake-file.inputs.zen.url = "github:0xc000022070/zen-browser-flake";

  den.aspects.zen.homeManager = {
    imports = [inputs.zen.homeModules.twilight];

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

        settings."zen.welcome-screen.seen" = true;
      };
    };
  };
}

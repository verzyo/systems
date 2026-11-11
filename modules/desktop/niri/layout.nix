{
  den.aspects.niri.homeManager.programs.niri.settings = let
    strut = -1;
  in {
    prefer-no-csd = true;

    layout = {
      preset-column-widths = [
        {proportion = 1. / 3.;}
        {proportion = 1. / 2.;}
        {proportion = 2. / 3.;}
      ];

      empty-workspace-above-first = true;
      always-center-single-column = false;
      center-focused-column = "never";

      gaps = 12.0 - strut;

      shadow.enable = false;

      border = {
        enable = true;
        width = 3;
      };

      focus-ring.enable = false;

      struts = {
        left = strut;
        right = strut;
        bottom = strut;
        top = strut;
      };
    };

    overview.workspace-shadow.enable = false;
  };
}

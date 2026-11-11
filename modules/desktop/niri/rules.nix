{
  den.aspects.niri.homeManager.programs.niri.settings = {
    window-rules = [
      {
        draw-border-with-background = false;
        clip-to-geometry = true;

        geometry-corner-radius = let
          r = 16.0;
        in {
          top-left = r;
          top-right = r;
          bottom-left = r;
          bottom-right = r;
        };
      }
    ];
  };
}

{
  den.aspects.niri.homeManager.programs.niri.settings = {
    cursor = {
      hide-when-typing = true;
      hide-after-inactive-ms = 5000;
    };

    input = {
      focus-follows-mouse = {
        enable = true;
        max-scroll-amount = "0%";
      };

      # power button = sleep
      power-key-handling.enable = true;

      keyboard = {
        repeat-delay = 250;
        repeat-rate = 35;

        numlock = true;
      };

      touchpad = {
        tap = true;

        drag-lock = true;
        natural-scroll = true;
      };

      mouse.accel-profile = "flat";
    };
  };
}

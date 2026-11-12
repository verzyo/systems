{
  den.aspects.foot.homeManager = {
    programs.foot.enable = true;

    xdg.terminal-exec = {
      enable = true;
      settings.default = ["foot.desktop"];
    };
  };
}

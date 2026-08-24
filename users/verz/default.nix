_: {
  modules = {
    programs = {
      zen.enable = true;
      foot.enable = true;

      jujutsu.enable = true;

      direnv.enable = true;
    };

    shell = {
      starship.enable = true;
      fish.enable = true;
    };

    desktop = {
      quickshell.enable = true;
      niri.enable = true;
    };
  };

  home = {
    username = "verz";
    homeDirectory = "/home/verz";
    stateVersion = "26.11";
  };
}

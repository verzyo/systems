_: {
  modules = {
    programs = {
      claude-code.enable = true;

      zen.enable = true;
      foot.enable = true;

      neovim.enable = true;

      direnv.enable = true;
      jujutsu.enable = true;
    };

    shell = {
      starship.enable = true;
      fish.enable = true;
    };

    services = {
      cliproxyapi.enable = true;

      syncthing.enable = true;
    };

    desktop = {
      quickshell.enable = true;
      niri.enable = true;
      matugen.enable = true;
      cursor.enable = true;
    };
  };

  home = {
    username = "verz";
    homeDirectory = "/home/verz";
    stateVersion = "26.11";
  };
}

{
  den.aspects.bat.homeManager = {
    programs.bat = {
      enable = true;
      config.style = "numbers,changes";
    };

    home.shellAliases.cat = "bat --paging=never";
  };
}

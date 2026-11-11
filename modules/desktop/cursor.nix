{
  den.aspects.cursor.homeManager = {pkgs, ...}: {
    home.pointerCursor = {
      enable = true;
      size = 20;

      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
    };
  };
}

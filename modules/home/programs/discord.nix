{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.programs.discord.enable {
    programs.equibop = {
      enable = true;

      equicord.settings = lib.mkIf config.modules.desktop.meowtugen.enable {
        enabledThemes = ["meowtugen.css"];
      };
    };

    home.activation.equibopSettings = let
      settings = {
        enableSplashScreen = false;
        splashTheming = true;
      };

      settingsFile = (pkgs.formats.json {}).generate "equibop-settings.json" settings;
      jq = lib.getExe pkgs.jq;
    in
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        TARGET="${config.xdg.configHome}/equibop/settings.json"
        $DRY_RUN_CMD mkdir -p "$(dirname "$TARGET")"

        if [ -f "$TARGET" ] && ${jq} -e . "$TARGET" >/dev/null 2>&1; then
          $DRY_RUN_CMD ${jq} -s '.[0] * ({splashColor: .[1].splashColor, splashBackground: .[1].splashBackground} | with_entries(select(.value != null)))' ${settingsFile} "$TARGET" > "$TARGET.tmp" \
            && $DRY_RUN_CMD ${jq} empty "$TARGET.tmp" \
            && $DRY_RUN_CMD mv "$TARGET.tmp" "$TARGET" \
            && $VERBOSE_ECHO "equibop: merged declarative settings, preserved splash colors"
        else
          $DRY_RUN_CMD install -Dm644 ${settingsFile} "$TARGET"
          $VERBOSE_ECHO "equibop: installed writable settings.json"
        fi
      '';
  };

  options.modules.programs.discord.enable = lib.mkEnableOption "discord module";
}

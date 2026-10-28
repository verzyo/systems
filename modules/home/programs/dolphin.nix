{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.programs.dolphin.enable {
    home.packages = with pkgs.kdePackages; [
      dolphin
      breeze-icons
      kio-extras
      ffmpegthumbs
      kdegraphics-thumbnailers
    ];

    # kde platform theme so dolphin reads the matugen-generated kdeglobals
    programs.m3owtugen.dolphin.setQtPlatformTheme = true;

    qt = {
      enable = true;
      platformTheme.name = "kde";
      style = {
        name = "darkly";
        package = pkgs.darkly;
      };

      # written with kwriteconfig6 so dolphin can still save its own state
      kde.settings = {
        darklyrc.Style.WidgetDrawShadow = false;

        dolphinrc = {
          DetailsMode.PreviewSize = 32;
          General = {
            GlobalViewProps = false;
            ShowFullPath = true;
            ShowStatusBar = "FullWidth";
          };
          "KFileDialog Settings" = {
            "Places Icons Auto-resize" = false;
            "Places Icons Static Size" = 22;
          };
          MainWindow.MenuBar = "Disabled";
          PreviewSettings.Plugins = lib.concatStringsSep "," [
            "ffmpegthumbs"
            "appimagethumbnail"
            "audiothumbnail"
            "avif"
            "comicbookthumbnail"
            "cursorthumbnail"
            "djvuthumbnail"
            "ebookthumbnail"
            "exrthumbnail"
            "directorythumbnail"
            "fontthumbnail"
            "heif"
            "imagethumbnail"
            "jpegthumbnail"
            "jxl"
            "kraorathumbnail"
            "windowsexethumbnail"
            "windowsimagethumbnail"
            "mobithumbnail"
            "opendocumentthumbnail"
            "gsthumbnail"
            "rawthumbnail"
            "svgthumbnail"
          ];
        };
      };
    };
  };

  options.modules.programs.dolphin.enable = lib.mkEnableOption "dolphin module";
}

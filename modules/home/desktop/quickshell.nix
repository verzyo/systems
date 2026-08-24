{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.desktop.quickshell.enable {
    programs.quickshell = {
      enable = true;

      package = pkgs.stdenv.mkDerivation {
        pname = "quickshell";
        version = pkgs.quickshell.version;

        dontUnpack = true;
        dontBuild = true;

        nativeBuildInputs = [pkgs.qt6.wrapQtAppsHook];
        buildInputs = with pkgs.kdePackages; [
          qtbase
          qtmultimedia
        ];

        installPhase = ''
          mkdir -p $out/bin $out/share

          ln -s ${pkgs.lib.getExe pkgs.quickshell} $out/bin/quickshell
          cp -r ${pkgs.quickshell}/share/* $out/share/ || true
        '';
      };
    };
  };

  options.modules.desktop.quickshell.enable = lib.mkEnableOption "quickshell module";
}

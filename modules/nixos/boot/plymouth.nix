{
  lib,
  config,
  pkgs,
  ...
}: let
  bgrt-logo = pkgs.runCommand "plymouth-theme-bgrt-logo" {} ''
    themeDir="$out/share/plymouth/themes/bgrt-logo"
    mkdir -p "$themeDir"

    # Copy dialog assets for password prompts (box, lock, entry, etc.)
    cp ${pkgs.plymouth}/share/plymouth/themes/spinner/*.png "$themeDir/" 2>/dev/null || true
    # Remove animation frames and watermark logo
    rm -f "$themeDir"/animation-*.png "$themeDir"/throbber-*.png "$themeDir"/watermark.png

    # Use a transparent 1x1 pixel as a single dummy frame so Plymouth idles cleanly without a spinner
    echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=" | ${pkgs.coreutils}/bin/base64 -d > "$themeDir/animation-0001.png"

    # Adapt upstream bgrt.plymouth config to use our asset directory
    ${pkgs.gnused}/bin/sed \
      -e "s|^ImageDir=.*|ImageDir=$themeDir|" \
      -e "s|^Name=BGRT|Name=BGRT Logo|" \
      ${pkgs.plymouth}/share/plymouth/themes/bgrt/bgrt.plymouth > "$themeDir/bgrt-logo.plymouth"
  '';
in {
  config = lib.mkIf config.modules.boot.plymouth.enable {
    boot = {
      plymouth = {
        enable = true;

        themePackages = [bgrt-logo];
        theme = "bgrt-logo";
      };

      consoleLogLevel = 0;

      kernelParams = [
        "splash"
        "quiet"
      ];
    };
  };

  options.modules.boot.plymouth.enable = lib.mkEnableOption "plymouth module";
}

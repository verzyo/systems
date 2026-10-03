{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.desktop.dank16.enable {
    home.packages = [
      (pkgs.buildGoModule {
        pname = "dank16";
        version = "unstable";

        src = "${inputs.dankmaterialshell}/core";
        vendorHash = "sha256-Vlhtg829lRKpHLQXcdZMBN/jRwxmg54YFnnSuUdYc5E=";

        subPackages = ["cmd/dank16"];
        preBuild = let
          mainGo = pkgs.writeText "main.go" ''
            package main

            func main() {
              _ = dank16Cmd.Execute()
            }
          '';
        in ''
          mkdir -p cmd/dank16

          cp cmd/dms/commands_dank16.go cmd/dank16/commands_dank16.go
          cp ${mainGo} cmd/dank16/main.go
        '';

        ldflags = [
          "-s"
          "-w"
        ];

        meta = {
          description = "Generate Base16 color palettes from a color with support for various output formats";
          homepage = "https://github.com/AvengeMedia/DankMaterialShell";
          license = lib.licenses.mit;
          mainProgram = "dank16";
        };
      })
    ];
  };

  options.modules.desktop.dank16.enable = lib.mkEnableOption "dank16 module";
}

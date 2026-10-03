{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  emptyConfig = pkgs.writeText "empty-matugen.toml" ''
    [config]
    [templates]
  '';
in {
  config = lib.mkIf config.modules.desktop.matugen.enable {
    home.packages = [
      (pkgs.buildGoModule {
        pname = "matugen";
        version = "unstable";

        src = "${inputs.dankmaterialshell}/core";
        vendorHash = "sha256-Vlhtg829lRKpHLQXcdZMBN/jRwxmg54YFnnSuUdYc5E=";

        subPackages = ["cmd/matugen-wrapper"];

        preBuild = let
          mainGo = pkgs.writeText "main.go" ''
            package main

            import (
            	"encoding/json"
            	"fmt"
            	"os"
            	"os/exec"
            	"strings"

            	"github.com/AvengeMedia/DankMaterialShell/core/internal/dank16"
            )

            func main() {
            	matugen := "${lib.getExe pkgs.matugen}"
            	emptyConfig := "${emptyConfig}"
            	args := os.Args[1:]

            	// Passthrough for non-theming commands (--help, --version, json, etc.)
            	if len(args) == 0 || (args[0] != "image" && args[0] != "color") {
            		cmd := exec.Command(matugen, args...)
            		cmd.Stdin, cmd.Stdout, cmd.Stderr = os.Stdin, os.Stdout, os.Stderr
            		_ = cmd.Run()
            		if cmd.ProcessState != nil {
            			os.Exit(cmd.ProcessState.ExitCode())
            		}
            		os.Exit(0)
            	}

            	// 1. Matugen dry run to extract Material 3 colors
            	var dryArgs []string
            	hasSourceIndex := false
            	hasContinueOnError := false
            	skipNext := false
            	for _, arg := range args {
            		if skipNext {
            			skipNext = false
            			continue
            		}
            		if arg == "-j" || arg == "--json" || arg == "-c" || arg == "--config" {
            			skipNext = true
            			continue
            		}
            		if strings.HasPrefix(arg, "-j=") || strings.HasPrefix(arg, "--json=") || arg == "--dry-run" || strings.HasPrefix(arg, "-c=") || strings.HasPrefix(arg, "--config=") {
            			continue
            		}
            		if arg == "--source-color-index" || strings.HasPrefix(arg, "--source-color-index=") {
            			hasSourceIndex = true
            		}
            		if arg == "--continue-on-error" {
            			hasContinueOnError = true
            		}
            		dryArgs = append(dryArgs, arg)
            	}
            	dryArgs = append(dryArgs, "-c", emptyConfig, "--json", "hex", "--dry-run", "--old-json-output")
            	if !hasSourceIndex {
            		dryArgs = append(dryArgs, "--source-color-index", "0")
            	}

            	out, err := exec.Command(matugen, dryArgs...).Output()
            	if err != nil {
            		fmt.Fprintf(os.Stderr, "matugen dry-run failed: %v\n", err)
            		os.Exit(1)
            	}

            	// 2. Extract colors (1:1 with DMS matugen.go)
            	var data map[string]any
            	_ = json.Unmarshal(out, &data)
            	colors, _ := data["colors"].(map[string]any)

            	extract := func(role, mode string) string {
            		if c, ok := colors[role].(map[string]any); ok {
            			if v, ok := c[mode].(string); ok {
            				return v
            			}
            		}
            		return ""
            	}

            	primaryDark := extract("primary", "dark")
            	primaryLight := extract("primary", "light")
            	if primaryDark == "" {
            		primaryDark = primaryLight
            	}
            	if primaryLight == "" {
            		primaryLight = primaryDark
            	}

            	mode := "dark"
            	for i, arg := range args {
            		if (arg == "-m" || arg == "--mode") && i+1 < len(args) {
            			mode = strings.ToLower(args[i+1])
            		} else if strings.HasPrefix(arg, "--mode=") {
            			mode = strings.ToLower(strings.TrimPrefix(arg, "--mode="))
            		}
            	}

            	// 3. Generate Dank16 base16 palette (1:1 with DMS generateDank16Variants)
            	variantOpts := dank16.VariantOptions{
            		PrimaryDark:     primaryDark,
            		PrimaryLight:    primaryLight,
            		BackgroundDark:  extract("surface", "dark"),
            		BackgroundLight: extract("surface", "light"),
            		ContainerDark:   extract("primary_container", "dark"),
            		ContainerLight:  extract("primary_container", "light"),
            		UseDPS:          true,
            		IsLightMode:     mode == "light",
            	}
            	variantColors := dank16.GenerateVariantPalette(variantOpts)
            	dank16JSON := dank16.GenerateVariantJSON(variantColors)

            	// 4. Run matugen with --import-json-string
            	finalArgs := append(args, "--import-json-string", fmt.Sprintf(`{"dank16": %s}`, dank16JSON))
            	if !hasSourceIndex {
            		finalArgs = append(finalArgs, "--source-color-index", "0")
            	}
            	if !hasContinueOnError {
            		finalArgs = append(finalArgs, "--continue-on-error")
            	}
            	cmd := exec.Command(matugen, finalArgs...)
            	cmd.Stdin, cmd.Stdout, cmd.Stderr = os.Stdin, os.Stdout, os.Stderr
            	_ = cmd.Run()
            	if cmd.ProcessState != nil {
            		os.Exit(cmd.ProcessState.ExitCode())
            	}
            	os.Exit(0)
            }
          '';
        in ''
          mkdir -p cmd/matugen-wrapper
          cp ${mainGo} cmd/matugen-wrapper/main.go
        '';

        postInstall = ''
          mv $out/bin/matugen-wrapper $out/bin/matugen
        '';

        ldflags = [
          "-s"
          "-w"
        ];

        meta = {
          description = "Generate Material Design themes using matugen with dank16 color integration";
          mainProgram = "matugen";
        };
      })
    ];

    xdg.configFile."matugen/config.toml".source = (pkgs.formats.toml {}).generate "matugen-config.toml" {
      config = {};

      templates = let
        templates = "${inputs.dankmaterialshell}/quickshell/matugen/templates";
        configHome = config.xdg.configHome;
      in {
        niri = {
          input_path = "${templates}/niri-colors.kdl";
          output_path = "${configHome}/niri/colors.kdl";
        };
      };
    };
  };

  options.modules.desktop.matugen.enable = lib.mkEnableOption "matugen module";
}

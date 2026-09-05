{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.desktop.niri.enable {
    programs.niri.settings = {
      input = {
        focus-follows-mouse.enable = true;

        power-key-handling.enable = true; # power button = sleep

        keyboard = {
          repeat-delay = 250;
          repeat-rate = 35;

          numlock = true;
        };

        touchpad = {
          tap = true;

          drag-lock = true;
          natural-scroll = true;
        };

        mouse.accel-profile = "flat";
      };

      outputs."eDP-1" = {
        scale = 1.2;
        mode = {
          width = 1920;
          height = 1080;
          refresh = 144.003;
        };
      };

      layout = {
        preset-column-widths = [
          {proportion = 1. / 3.;}
          {proportion = 1. / 2.;}
          {proportion = 2. / 3.;}
        ];

        empty-workspace-above-first = true;
        always-center-single-column = false;
        center-focused-column = "never";

        background-color = "transparent";
        shadow.enable = false;

        border = {
          enable = true;
          width = 3;

          active.color = "#FFFFFF";
          inactive.color = "#808080";
        };

        focus-ring.enable = false;
      };

      overview.workspace-shadow.enable = false;

      window-rules = [
        {
          draw-border-with-background = false;
          clip-to-geometry = true;

          geometry-corner-radius = let
            r = 12.0;
          in {
            top-left = r;
            top-right = r;
            bottom-left = r;
            bottom-right = r;
          };
        }
      ];

      layer-rules = [
        {
          matches = [{namespace = "wallpaper";}];
          place-within-backdrop = true;
        }
      ];

      binds = let
        wpctl = "${pkgs.wireplumber}/bin/wpctl";
        brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
        playerctl = "${pkgs.playerctl}/bin/playerctl";
      in {
        "Mod+Return" = {
          repeat = false;
          action.spawn = "footclient";
        };

        "Mod+O" = {action.toggle-overview = {};};
        "Mod+F" = {action.maximize-column = {};};
        "Mod+Alt+F" = {action.fullscreen-window = {};};
        "Mod+R" = {action.switch-preset-column-width = {};};
        "Mod+W" = {action.close-window = {};};

        "Mod+H" = {action.focus-column-left = {};};
        "Mod+L" = {action.focus-column-right = {};};
        "Mod+J" = {action.focus-workspace-down = {};};
        "Mod+K" = {action.focus-workspace-up = {};};

        "Mod+U" = {action.focus-column-first = {};};
        "Mod+I" = {action.focus-column-last = {};};

        "Mod+Left" = {action.consume-or-expel-window-left = {};};
        "Mod+Right" = {action.consume-or-expel-window-right = {};};
        "Mod+Down" = {action.focus-window-down = {};};
        "Mod+Up" = {action.focus-window-up = {};};

        "Mod+Alt+H" = {action.swap-window-left = {};};
        "Mod+Alt+L" = {action.swap-window-right = {};};
        "Mod+Alt+J" = {action.move-workspace-down = {};};
        "Mod+Alt+K" = {action.move-workspace-up = {};};

        "XF86MonBrightnessUp" = {
          allow-when-locked = true;
          action.spawn = [brightnessctl "--class=backlight" "set" "+10%"];
        };
        "XF86MonBrightnessDown" = {
          allow-when-locked = true;
          action.spawn = [brightnessctl "--class=backlight" "set" "10%-" "-n"];
        };
        "XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action.spawn = [wpctl "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+" "-l" "1.0"];
        };
        "XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action.spawn = [wpctl "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"];
        };
        "XF86AudioPrev" = {
          repeat = false;
          allow-when-locked = true;
          action.spawn = [playerctl "previous"];
        };
        "XF86AudioNext" = {
          repeat = false;
          allow-when-locked = true;
          action.spawn = [playerctl "next"];
        };
        "XF86AudioRewind" = {
          allow-when-locked = true;
          action.spawn = [playerctl "position" "5-"];
        };
        "XF86AudioForward" = {
          allow-when-locked = true;
          action.spawn = [playerctl "position" "5+"];
        };
        "XF86AudioMute" = {
          repeat = false;
          allow-when-locked = true;
          action.spawn = [wpctl "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];
        };
        "XF86AudioMicMute" = {
          repeat = false;
          allow-when-locked = true;
          action.spawn = [wpctl "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"];
        };
        "XF86AudioPlay" = {
          repeat = false;
          allow-when-locked = true;
          action.spawn = [playerctl "play-pause"];
        };
        "XF86AudioStop" = {
          repeat = false;
          allow-when-locked = true;
          action.spawn = [playerctl "stop"];
        };
      };

      prefer-no-csd = true;
    };
  };

  options.modules.desktop.niri.enable = lib.mkEnableOption "niri module";
}

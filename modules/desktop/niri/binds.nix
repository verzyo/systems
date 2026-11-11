{
  den.aspects.niri.homeManager = {
    pkgs,
    lib,
    ...
  }: {
    programs.niri.settings = {
      hotkey-overlay.skip-at-startup = true;

      binds = let
        wpctl = lib.getExe' pkgs.wireplumber "wpctl";
        brightnessctl = lib.getExe pkgs.brightnessctl;
        playerctl = lib.getExe pkgs.playerctl;
      in {
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
    };
  };
}

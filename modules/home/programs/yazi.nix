{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.programs.yazi.enable {
    programs.yazi = {
      enable = true;

      plugins = let
        luaHelper = pkgs.writeText "helper.lua" ''
          local _raw_emit = ya.mgr_emit or ya.emit
          local function mgr_emit(name, args)
            local coerced = {}
            for k, v in pairs(args or {}) do
              if type(v) == "number" then
                coerced[k] = tostring(v)
              else
                coerced[k] = v
              end
            end
            local ok, err = pcall(_raw_emit, name, coerced)
            if not ok then
              ya.notify({ title = "relative-motions error", content = tostring(err), level = "error", timeout = 10 })
            end
            return ok
          end
        '';
      in {
        relative-motions = pkgs.runCommand "relative-motions.yazi" {} ''
          cp -r ${pkgs.fetchFromGitHub {
            owner = "dedukun";
            repo = "relative-motions.yazi";
            rev = "main";
            hash = "sha256-9i6x/VxGOA3bB3FPieB7mQ1zGaMK5wnMhYqsq4CvaM4=";
          }} $out
          chmod -R +w $out
          substituteInPlace $out/main.lua \
            --replace-warn 'ya.mgr_emit' 'mgr_emit'

          cat ${luaHelper} $out/main.lua > $out/main.lua.tmp
          mv $out/main.lua.tmp $out/main.lua
        '';
      };

      initLua = ''
        require("relative-motions"):setup({
          show_numbers = "relative_absolute",
          show_motion = true,
          only_motions = false,
        })
      '';

      keymap = {
        mgr.prepend_keymap =
          builtins.genList (i: {
            on = [(toString (i + 1))];
            run = "plugin relative-motions ${toString (i + 1)}";
            desc = "Move in relative steps";
          })
          9;
      };
    };
  };

  options.modules.programs.yazi.enable = lib.mkEnableOption "yazi module";
}

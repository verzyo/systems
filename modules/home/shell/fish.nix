{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.programs.fish.enable {
    programs.fish = {
      enable = true;

      interactiveShellInit =
        ''
          set fish_greeting

          fish_vi_key_bindings

          bind -M insert ctrl-backspace backward-kill-word
          bind -M insert ctrl-delete kill-word
        ''
        + lib.optionalString config.programs.jujutsu.enable ''
          ${lib.getExe config.programs.jujutsu.package} util completion fish | source
        '';
    };
  };

  options.modules.programs.fish.enable = lib.mkEnableOption "fish module";
}

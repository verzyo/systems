{
  nixos.modules.fish = {
    programs.fish.enable = true;
  };

  home.modules.fish = {
    programs.fish = {
      enable = true;

      interactiveShellInit = ''
        set fish_greeting

        fish_vi_key_bindings

        bind -M insert ctrl-backspace backward-kill-word
        bind -M insert ctrl-delete kill-word
      '';
    };
  };
}

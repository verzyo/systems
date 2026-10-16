{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.programs.vim.enable {
    programs.vim.enable = true;
  };

  options.modules.programs.vim.enable = lib.mkEnableOption "vim module";
}

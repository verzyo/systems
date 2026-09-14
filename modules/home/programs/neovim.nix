{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.modules.programs.neovim.enable {
    programs.neovim = {
      enable = true;

      plugins = with pkgs.vimPlugins; [
        obsidian-nvim
        plenary-nvim
      ];

      extraLuaConfig = ''
        vim.opt.conceallevel = 2

        require("obsidian").setup({
          legacy_commands = false,
          frontmatter = {
            enabled = false,
          },
          attachments = {
            folder = ".",
          },

          workspaces = {
            {
              name = "notes",
              path = "~/notes",
            },
          },

          note_id_func = function(title)
            if title ~= nil then
              local clean_title = title:gsub("^%s+", ""):gsub("%s+$", "")

              if clean_title ~= "" then
                return clean_title:gsub("[/\\?%%*:|\"<>]", "")
              end
            end

            return os.date("%Y-%m-%d")
          end,
        })
      '';
    };
  };

  options.modules.programs.neovim.enable = lib.mkEnableOption "neovim module";
}

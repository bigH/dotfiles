mapper = require "keymapper"

local n = mapper.n
local v = mapper.v

return {
  {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- or if using mini.icons/mini.nvim
    -- dependencies = { "echasnovski/mini.icons" },
    config = function(_, opts)
      local actions = require("fzf-lua").actions
      require("fzf-lua").setup({
        "hide",
        keymap = {
          builtin = {
            true,
          },
          fzf = {
            true,
          },
        },
        actions = {
          files = {
            true,
            ["enter"]       = actions.file_edit,
          },
        },
      })

      n("<LEADER>e",
        function()
          require("fzf-lua").files({})
        end)

      n("<LEADER>E",
        function()
          require("fzf-lua").files({ no_ignore = true })
        end)

      n("<LEADER>f",
        function()
          require("fzf-lua").live_grep({})
        end)

      n("<LEADER>F",
        function()
          require("fzf-lua").live_grep({ no_ignore = true })
        end)
    end,
    enabled = function()
      return not vim.g.vscode
    end,
  },
}

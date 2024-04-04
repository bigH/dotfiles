-- helps with nvim-tree apparently (see nvim-tree.disable_netrw)
vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1

require('setup_packer')

require('settings')
require('keymap')

-- if vim.fn.isdirectory(os.getenv("HOME") .. '/.hiren') then
--   require('dotfile_enhancements')
-- end

-- load premade plugins
require('plugins')

-- plugin-dependent configurations of LSP things
if not vim.g.vscode then
  require('color_star').setup()

  require('lsp_setup').setup()
  require('dap_setup').setup()
  require('lint_and_format').setup()

  -- TODO this breaks FZF integration
  -- require('terminal').setup()

  vim.cmd[[colorscheme tokyonight]]
end

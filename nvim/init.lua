-- helps with nvim-tree apparently (see nvim-tree.disable_netrw)
vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1

if vim.fn.exists('g:neovide') then
  -- setup sets the neovide profiler key binding
  require('neovide').setup()
end

require('setup_packer')

require('settings')
require('keymap')

-- load premade plugins
require('plugins')

-- plugin-dependent configurations of LSP things
require('lsp_setup').setup()
require('dap_setup').setup()
require('lint_and_format').setup()

-- load my own "plugins"

-- TODO this breaks FZF integration
-- require('terminal').setup()

vim.cmd[[colorscheme tokyonight]]

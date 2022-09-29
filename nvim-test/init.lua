vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  use {
    'ibhagwan/fzf-lua',
    requires = { 'kyazdani42/nvim-web-devicons' },
    config = function()
      require('fzf-lua').setup({})
    end
  }
end)


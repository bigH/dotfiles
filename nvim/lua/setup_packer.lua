vim.cmd [[packadd packer.nvim]]

require('packer').startup(function(use)
  ------- packages

  -- packer can manage itself
  use 'wbthomason/packer.nvim'

  ------- looks/ergo

  -- color-scheme
  use 'folke/tokyonight.nvim'

  -- file navigation tree
  use {
    'kyazdani42/nvim-tree.lua',
    requires = 'kyazdani42/nvim-web-devicons',
  }

  -- better status line
  use {
    'nvim-lualine/lualine.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
  }

  -- buffer-line
  use {
    'akinsho/bufferline.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
    tag = 'v3.*',
  }

  ------- text objects

  -- user-defined text objects
  use 'kana/vim-textobj-user'

  -- `ai`, `ii`
  use 'kana/vim-textobj-indent'

  -- `ae`, `ie`
  use 'kana/vim-textobj-entire'

  -- `a,` `i,`
  use 'b4winckler/vim-angry'

  -- `av`, `iv`
  use 'Julian/vim-textobj-variable-segment'

  -- `[` and `]` to use cursor to end of or beginning of text object - e.g. `c[ip`, `c]i)`
  use 'tommcdo/vim-ninja-feet'

  ------- text manipulation

  -- `cx` to exchange
  use 'tommcdo/vim-exchange'

  -- `gl` to align
  use 'tommcdo/vim-lion'

  -- surround
  use {
    'kylechui/nvim-surround',
    tag = '*',
  }

  -- `gc`/`gb` to comment
  use 'numToStr/Comment.nvim'

  -- `gr` to replace in text-objects
  use 'vim-scripts/ReplaceWithRegister'

  ------- git stuff

  use {
    'lewis6991/gitsigns.nvim',
    tag = 'v0.6'
  }

  ------- visual/structural helpers

  -- tree sitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
  }

  -- highlight current token
  use {
    'RRethy/vim-illuminate',
    requires = 'kyazdani42/nvim-web-devicons',
  }

  -- indent guides
  use 'lukas-reineke/indent-blankline.nvim'

  ------- editing utilities

  -- auto-insert closer and handle <CR> properly also
  use 'windwp/nvim-autopairs'

  ------- pickers

  use {
    'ibhagwan/fzf-lua',
    requires = { 'kyazdani42/nvim-web-devicons' }
  }

  ------- completion/lsp

  use 'neovim/nvim-lspconfig'
  use 'folke/neodev.nvim'

  use 'hrsh7th/nvim-cmp'

  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-path'
  use 'ray-x/cmp-treesitter'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/cmp-emoji'
  use 'dmitmel/cmp-cmdline-history'

  use 'onsails/lspkind.nvim'

  use {
    'folke/trouble.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
  }

  ------- debugging

  use 'mfussenegger/nvim-dap'

  use {
    'rcarriga/nvim-dap-ui',
    requires = 'mfussenegger/nvim-dap',
  }

  use {
    'leoluz/nvim-dap-go',
    requires = 'mfussenegger/nvim-dap',
  }

  use {
    'theHamsta/nvim-dap-virtual-text',
    requires = 'mfussenegger/nvim-dap',
  }

  ------- copilot

  use 'github/copilot.vim'
  use {
    'jackMort/ChatGPT.nvim',
    requires = {
      'MunifTanjim/nui.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    }
  }


  ------- python

  use 'Vimjas/vim-python-pep8-indent'
  use 'averms/black-nvim'

end)

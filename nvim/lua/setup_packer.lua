vim.cmd [[packadd packer.nvim]]

local isVSCode = vim.g.vscode == 1

require('packer').startup(function(use)
  ------- packages

  -- packer can manage itself
  use 'wbthomason/packer.nvim'

  ------- looks/ergo

  -- color-scheme
  use {
    'folke/tokyonight.nvim',
    disable = isVSCode,
  }

  -- file navigation tree
  use {
    'kyazdani42/nvim-tree.lua',
    requires = 'kyazdani42/nvim-web-devicons',
    disable = isVSCode,
  }

  -- better status line
  use {
    'nvim-lualine/lualine.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
    disable = isVSCode,
  }

  -- buffer-line
  use {
    'akinsho/bufferline.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
    tag = 'v3.*',
    disable = isVSCode,
  }

  -- colorize text containing terminal color
  -- NB: this plugin is not initialized automatically, instead you must manually require/use it
  use {
    'm00qek/baleia.nvim',
    tag = 'v1.4.0',
    disable = isVSCode,
  }


  ------- text objects

  -- user-defined text objects
  use 'kana/vim-textobj-user'

  -- `ai`, `ii` for indentation
  use 'kana/vim-textobj-indent'

  -- `ae`, `ie` for entire buffer
  use 'kana/vim-textobj-entire'

  -- `a,` `i,` for comma-separated lists
  use 'b4winckler/vim-angry'

  -- `av`, `iv` for variable segments
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
  use {
    'numToStr/Comment.nvim',
    disable = isVSCode,
  }

  -- `gr` to replace in text-objects
  use 'vim-scripts/ReplaceWithRegister'

  ------- git stuff

  use {
    'lewis6991/gitsigns.nvim',
    tag = 'v0.6',
    disable = isVSCode,
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
    disable = isVSCode,
  }

  -- rainbow delimiters
  use {
    'HiPhish/rainbow-delimiters.nvim',
    disable = isVSCode,
  }

  -- indent guides
  use {
    'lukas-reineke/indent-blankline.nvim',
    disable = isVSCode,
  }

  ------- editing utilities

  -- auto-insert closer and handle <CR> properly also
  use 'windwp/nvim-autopairs'
 
  use {
    'Wansmer/treesj',
    requires = { 'nvim-treesitter/nvim-treesitter' },
  }


  ------- pickers

  use {
    'ibhagwan/fzf-lua',
    requires = { 'kyazdani42/nvim-web-devicons' },
    disable = isVSCode,
  }

  ------- completion/lsp

  use {
    'neovim/nvim-lspconfig',
    disable = isVSCode,
  }
  use {
    'folke/neodev.nvim',
    disable = isVSCode,
  }

  use {
    'hrsh7th/nvim-cmp',
    disable = isVSCode,
  }

  use {
    'hrsh7th/cmp-nvim-lsp',
    disable = isVSCode,
  }
  use {
    'hrsh7th/cmp-path',
    disable = isVSCode,
  }
  use {
    'ray-x/cmp-treesitter',
    disable = isVSCode,
  }
  use {
    'hrsh7th/cmp-buffer',
    disable = isVSCode,
  }
  use {
    'hrsh7th/cmp-cmdline',
    disable = isVSCode,
  }
  use {
    'hrsh7th/cmp-emoji',
    disable = isVSCode,
  }
  use {
    'dmitmel/cmp-cmdline-history',
    disable = isVSCode,
  }

  use {
    'onsails/lspkind.nvim',
    disable = isVSCode,
  }

  use {
    'folke/trouble.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
    disable = isVSCode,
  }

  ------- debugging

  use {
    'mfussenegger/nvim-dap',
    disable = isVSCode,
  }

  use {
    'rcarriga/nvim-dap-ui',
    requires = {
      'mfussenegger/nvim-dap',
      'nvim-neotest/nvim-nio',
    },
    disable = isVSCode,
  }

  use {
    'leoluz/nvim-dap-go',
    requires = 'mfussenegger/nvim-dap',
    disable = isVSCode,
  }

  use {
    'theHamsta/nvim-dap-virtual-text',
    requires = 'mfussenegger/nvim-dap',
    disable = isVSCode,
  }

  ------- copilot

  use {
    'github/copilot.vim',
    disable = isVSCode,
  }
  use {
    'jackMort/ChatGPT.nvim',
    requires = {
      'MunifTanjim/nui.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
    disable = isVSCode,
  }

end)

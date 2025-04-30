return {
  -- nightfox scheme
  {
    "EdenEast/nightfox.nvim",
    lazy = false,
    opts = {
      options = {
        styles = {
          comments = "italic",
          keywords = "bold",
          types = "italic,bold",
        },
      },
    },
    config = function(_, opts)
      require("nightfox").setup()
      vim.cmd("colorscheme nightfox")
    end,
    enabled = function()
      return not vim.g.vscode
    end,
  },
  {
    'romgrk/barbar.nvim',
    dependencies = {
      'lewis6991/gitsigns.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    init = function() vim.g.barbar_auto_setup = false end,
    opts = {
      animation = false,
    },
    version = '^1.0.0', -- optional: only update when a new 1.x version is released
    enabled = function()
      return not vim.g.vscode
    end,
  },
  {
    "norcalli/nvim-colorizer.lua",
    opts = {},
    config = function(_, opts)
      require("colorizer").setup(opts)
    end,
    enabled = function()
      return not vim.g.vscode
    end,
  },
}


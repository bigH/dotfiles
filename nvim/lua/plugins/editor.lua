entire_file_region = function()
  local from = { line = 1, col = 1 }
  local to = {
    line = vim.fn.line('$'),
    col = math.max(vim.fn.getline('$'):len(), 1)
  }
  return { from = from, to = to, vis_mode = 'V' }
end

return {
  -- tree-sitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },

  -- comments
  { "folke/ts-comments.nvim" },

  -- auto pairs
  {
    "echasnovski/mini.pairs",
    version = "*",
    opts = {
      modes = { insert = true, command = true, terminal = false },
      -- skip autopair when next character is one of these
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      -- skip autopair when the cursor is inside these treesitter nodes
      skip_ts = { "string" },
      -- skip autopair when next character is closing pair
      -- and there are more closing pairs than opening pairs
      skip_unbalanced = true,
      -- better deal with markdown code blocks
      markdown = true,
    },
    config = function(_, opts)
      require('mini.pairs').setup(opts)
    end
  },

  -- operators for convenience
  {
    "echasnovski/mini.operators",
    version = "*",
    opts = {
      sort = {
        prefix = nil,
        func = nil,
      },
    },
    config = function(_, opts)
      require('mini.operators').setup(opts)
    end
  },

  -- Better text-objects
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          x = ai.gen_spec.treesitter({ -- code block
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
          d = { "%f[%d]%d+" }, -- digits
          e = entire_file_region,
          u = ai.gen_spec.function_call(), -- u for "Usage"
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
        },
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)
    end,
  },

  -- Surround stuff
  {
    "kylechui/nvim-surround",
    version = "^3.0.0",
    event = "VeryLazy",
    opts = {
      keymaps = {
        insert = "<C-g>s",
        insert_line = "<C-g>S",
        normal = "gs",
        normal_cur = "gss",
        normal_line = "gS",
        normal_cur_line = "gSS",
        visual = "gs",
        visual_line = "gS",
        delete = "ds",
        change = "cs",
        change_line = "cS",
      },
    },
    config = function(_, opts)
      require("nvim-surround").setup(opts)
    end,
  },
}

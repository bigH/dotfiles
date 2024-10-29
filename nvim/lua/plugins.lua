local configs = require('configs')
local map = require('keymapper')
local utils = configs.utils

local n = map.n
local v = map.v
local i = map.i

local isVSCode = vim.g.vscode == 1

--

if not isVSCode then
  require('tokyonight').setup(configs.colorconfig)

--

  local fzf = require('fzf-lua')

  local actions = fzf.actions
  fzf.setup({
    'fzf-native',
    actions = {
      files = {
        ['default'] = actions.file_edit
      }
    },
    previewers = {
      git_diff = {
        pager = "delta --width=$FZF_PREVIEW_COLUMNS"
      }
    }
  })

  function get_preview_setting()
    local preview_setting = '60%:right'
    local preview_executable = os.getenv("DOT_FILES_DIR") .. '/auto-sized-fzf/auto-sized-fzf.sh'
    if vim.fn.executable(preview_executable) then
      preview_setting = vim.fn.system(preview_executable)
    end
    return preview_setting
  end

  n('<LEADER>e', function()
    fzf.files({ cmd = 'fd --hidden' })
  end)

  n('<LEADER>E', function()
    fzf.files({ cmd = 'fd --hidden --no-ignore' })
  end)

  n('<LEADER>F', fzf.live_grep)
  n('<LEADER>f', fzf.live_grep_resume)
  v('<LEADER>f', fzf.grep_visual)
  n('<LEADER>j', fzf.lgrep_curbuf)
  n('<LEADER>o', fzf.git_status)

  --

  require('nvim-tree').setup({
    update_focused_file = {
      enable = true,
    },
  })
  n('<F1>', '<CMD>NvimTreeToggle<CR>')
  i('<F1>', '<ESC><CMD>NvimTreeToggle<CR>')

  --

  local bubbles_theme = {
    normal = {
      a = { fg = configs.colors.blue, bg = configs.colors.bg },
      b = { fg = configs.colors.fg, bg = configs.colors.bg },
      c = { fg = configs.colors.bg, bg = configs.colors.bg_highlight },
    },

    insert = { a = { fg = configs.colors.bg, bg = configs.colors.blue } },
    visual = { a = { fg = configs.colors.bg, bg = configs.colors.cyan } },
    replace = { a = { fg = configs.colors.bg, bg = configs.colors.red } },

    inactive = {
      a = { fg = configs.colors.fg, bg = configs.colors.bg_dark },
      b = { fg = configs.colors.fg, bg = configs.colors.bg_dark },
      c = { fg = configs.colors.bg, bg = configs.colors.bg_dark },
    },
  }

  require('lualine').setup({
    options = {
      icons_enabled = true,
      theme = bubbles_theme,
      component_separators = '|',
      section_separators = { left = '', right = '' },
      ignore_focus = configs.special_windows,
    },
    sections = {
      lualine_a = {
        { 'mode', separator = { left = '' }, right_padding = 2 },
      },
      lualine_b = {
        'fileformat',
        {
          'filename',
          path = 1,
        },
        'branch',
      },
      lualine_c = {},
      lualine_x = {},
      lualine_y = { 'filetype', 'progress' },
      lualine_z = {
        { 'location', separator = { right = '' }, left_padding = 2 },
      },
    },
    inactive_sections = {
      lualine_a = { 'filename' },
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = { 'location' },
    },
    tabline = {},
    extensions = {},
  })

  --

  require('bufferline').setup({
    options = {
      indicator = {
        style = 'underline'
      },
    },
  })

  --

  require('illuminate').configure({
    providers = {
      'lsp',
      'treesitter',
      'regex',
    },
    delay = 100,
  })

  --

  require('Comment').setup({
    ignore = '^(%s*)$',
    mappings = {
      basic = true,
      extra = true,
    },
  })

  --

  vim.api.nvim_set_hl(0, "RainbowDelimiterRed"   , { fg = configs.colors.red   , bg = configs.dark_bg_indent })
  vim.api.nvim_set_hl(0, "RainbowDelimiterYellow", { fg = configs.colors.yellow, bg = configs.light_bg_indent })
  vim.api.nvim_set_hl(0, "RainbowDelimiterBlue"  , { fg = configs.colors.blue  , bg = configs.dark_bg_indent })
  vim.api.nvim_set_hl(0, "RainbowDelimiterOrange", { fg = configs.colors.orange, bg = configs.light_bg_indent })
  vim.api.nvim_set_hl(0, "RainbowDelimiterGreen" , { fg = configs.colors.green , bg = configs.dark_bg_indent })
  vim.api.nvim_set_hl(0, "RainbowDelimiterViolet", { fg = configs.colors.violet, bg = configs.light_bg_indent })

  local rainbow_delimiters = require('rainbow-delimiters')

  vim.g.rainbow_delimiters = {
      strategy = {
          [''] = rainbow_delimiters.strategy['global'],
          vim = rainbow_delimiters.strategy['local'],
      },
      query = {
          [''] = 'rainbow-delimiters',
          lua = 'rainbow-blocks',
      },
      priority = {
          [''] = 110,
          lua = 210,
      },
      highlight = {
          'RainbowDelimiterRed',
          'RainbowDelimiterYellow',
          'RainbowDelimiterBlue',
          'RainbowDelimiterOrange',
          'RainbowDelimiterGreen',
          'RainbowDelimiterViolet',
      },
  }

  --

  local highlight = {
      "RainbowIndentRed",
      "RainbowIndentYellow",
      "RainbowIndentBlue",
      "RainbowIndentOrange",
      "RainbowIndentGreen",
      "RainbowIndentViolet",
  }

  local hooks = require("ibl.hooks")

  hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      vim.api.nvim_set_hl(0, "RainbowIndentRed"   , { fg = configs.blendToBackground(configs.colors.red)   , bg = configs.dark_bg_indent })
      vim.api.nvim_set_hl(0, "RainbowIndentYellow", { fg = configs.blendToBackground(configs.colors.yellow), bg = configs.light_bg_indent })
      vim.api.nvim_set_hl(0, "RainbowIndentBlue"  , { fg = configs.blendToBackground(configs.colors.blue)  , bg = configs.dark_bg_indent })
      vim.api.nvim_set_hl(0, "RainbowIndentOrange", { fg = configs.blendToBackground(configs.colors.orange), bg = configs.light_bg_indent })
      vim.api.nvim_set_hl(0, "RainbowIndentGreen" , { fg = configs.blendToBackground(configs.colors.green) , bg = configs.dark_bg_indent })
      vim.api.nvim_set_hl(0, "RainbowIndentViolet", { fg = configs.blendToBackground(configs.colors.violet), bg = configs.light_bg_indent })
  end)

  require("ibl").setup { scope = { highlight = highlight } }

  hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)

  --

  require('gitsigns').setup({
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text_pos = 'eol',
    },
  })

  --

  require('lspkind').init({
      mode = 'symbol_text',
      preset = 'codicons',
      symbol_map = {
        Text = "",
        Method = "",
        Function = "",
        Constructor = "",
        Field = "ﰠ",
        Variable = "",
        Class = "ﴯ",
        Interface = "",
        Module = "",
        Property = "ﰠ",
        Unit = "塞",
        Value = "",
        Enum = "",
        Keyword = "",
        Snippet = "",
        Color = "",
        File = "",
        Reference = "",
        Folder = "",
        EnumMember = "",
        Constant = "",
        Struct = "פּ",
        Event = "",
        Operator = "",
        TypeParameter = ""
      },
  })

  --

  if vim.env.OPENAI_API_KEY ~= nil then
    require("chatgpt").setup()
  end

  --

  require("trouble").setup()

  n('<F2>', '<CMD>TroubleToggle workspace_diagnostics<CR>')
  i('<F2>', '<ESC><CMD>TroubleToggle workspace_diagnostics<CR>')

  --

  require('nvim-autopairs').setup({
    disable_filetype = { "TelescopePrompt" , "vim" },
  })

end

--

require('nvim-surround').setup({
  keymaps = {
    normal = 's',
    normal_cur = 'ss',
    normal_line = 'S',
    normal_cur_line = 'SS',
    insert = '<C-g>s',
    insert_line = '<C-g>S',
    visual = 'S',
    visual_line = 'gS',
    delete = 'ds',
    change = 'cs',
  },
})

--

require('nvim-treesitter.configs').setup({
  ensure_installed = 'all',
  ignore_install = { 
    'smali'
  },

  sync_install = false,

  auto_install = true,

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },

  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<M-x>',
      node_incremental = '<M-x>',
      scope_incremental = '<M-X>',
      node_decremental = '<M-c>',
    },
  },
})

--

local sj = require("treesj")

sj.setup()

n('<c-j>', function()
  sj.split({ split = { recursive = true } })
end)

n('<c-k>', function()
  sj.join()
end)

i('<c-j>', function()
  sj.split({ split = { recursive = true } })
end)

i('<c-k>', function()
  sj.join()
end)

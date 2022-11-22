local configs = require('configs')
local map = require('keymapper')
local utils = require('utils')

local n = map.n
local v = map.v
local i = map.i

--

require('tokyonight').setup(configs.colorconfig)

--

local fzf = require('fzf-lua')
fzf.setup({})
n('<LEADER>e', fzf.files)
n('<LEADER>f', fzf.live_grep)
n('<LEADER>j', fzf.lgrep_curbuf)
v('<LEADER>f', fzf.grep_visual)
n('<LEADER>o', fzf.oldfiles)

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

local function blendToBackground(color)
  return utils.blendColors(configs.colors.bg, color, 0.85)
end

local dark_bg_indent = utils.blendColors(configs.colors.bg, configs.colors.bg_highlight, 0.95)
local light_bg_indent = utils.blendColors(configs.colors.bg, configs.colors.bg_highlight, 0.65)

vim.cmd('highlight IndentBlanklineIndent1 guibg=' .. dark_bg_indent  .. ' guifg=' .. blendToBackground(configs.colors.red) .. ' gui=nocombine')
vim.cmd('highlight IndentBlanklineIndent2 guibg=' .. light_bg_indent .. ' guifg=' .. blendToBackground(configs.colors.orange) .. ' gui=nocombine')
vim.cmd('highlight IndentBlanklineIndent3 guibg=' .. dark_bg_indent  .. ' guifg=' .. blendToBackground(configs.colors.yellow) .. ' gui=nocombine')
vim.cmd('highlight IndentBlanklineIndent4 guibg=' .. light_bg_indent .. ' guifg=' .. blendToBackground(configs.colors.green) .. ' gui=nocombine')
vim.cmd('highlight IndentBlanklineIndent5 guibg=' .. dark_bg_indent  .. ' guifg=' .. blendToBackground(configs.colors.teal) .. ' gui=nocombine')
vim.cmd('highlight IndentBlanklineIndent6 guibg=' .. light_bg_indent .. ' guifg=' .. blendToBackground(configs.colors.blue) .. ' gui=nocombine')

require('indent_blankline').setup({
  space_char_blankline = ' ',
  show_current_context = true,
  use_treesitter = true,
  char_highlight_list = {
    'IndentBlanklineIndent1',
    'IndentBlanklineIndent2',
    'IndentBlanklineIndent3',
    'IndentBlanklineIndent4',
    'IndentBlanklineIndent5',
    'IndentBlanklineIndent6',
  },
  space_char_highlight_list = {
    'IndentBlanklineIndent1',
    'IndentBlanklineIndent2',
    'IndentBlanklineIndent3',
    'IndentBlanklineIndent4',
    'IndentBlanklineIndent5',
    'IndentBlanklineIndent6',
  },
})

--

require('gitsigns').setup({
  current_line_blame = true,
  current_line_blame_opts = {
    virt_text_pos = 'eol',
  },
})

--

require('nvim-autopairs').setup({
  disable_filetype = { "TelescopePrompt" , "vim" },
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

require("trouble").setup()

n('<F2>', '<CMD>TroubleToggle workspace_diagnostics<CR>')
i('<F2>', '<ESC><CMD>TroubleToggle workspace_diagnostics<CR>')

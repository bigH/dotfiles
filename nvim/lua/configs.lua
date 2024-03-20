local M = {}

M.utils = require('utils')

M.special_windows = {
  'qf',
  'vista_kind',
  'terminal',
  'packer',
  'dap-repl',
  'dapui_stacks',
  'dapui_watches',
  'dapui_breakpoints',
  'dapui_console',
  'dapui_scopes',
  'dapui_repl',
  'dapui_controls',
  'dapui_state',
}

M.colorconfig = {
  style = 'night',
  sidebars = M.special_windows,
  dim_inactive = true,
  hide_inactive_statusline = false,
}

M.colors = require('tokyonight.colors').setup(M.colorconfig)

function M.blendToBackground(color)
  return M.utils.blendColors(M.colors.bg, color, 0.85)
end

M.dark_bg_indent  = M.utils.blendColors(M.colors.bg, M.colors.bg_highlight, 0.95)
M.light_bg_indent = M.utils.blendColors(M.colors.bg, M.colors.bg_highlight, 0.65)

return M

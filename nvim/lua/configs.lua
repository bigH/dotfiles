local M = {}

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

return M

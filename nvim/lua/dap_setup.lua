local M = {}

local configs = require('configs')
local map = require('keymapper')

local n = map.n

function M.setup()
  -- local dap = require('dap')
  -- local dap_ui = require('dapui')
  -- local dap_go = require('dap-go')
  -- local dap_virtual_text = require("nvim-dap-virtual-text")


  -- vim.fn.sign_define('DapBreakpoint', {text='🛑', texthl='', linehl=configs.colors.dark3, numhl=''})
  -- vim.fn.sign_define('DapBreakpointCondition', {text='❓', texthl='', linehl=configs.colors.dark3, numhl=''})
  -- vim.fn.sign_define('DapLogPoint', {text='📣', texthl='', linehl=configs.colors.dark3, numhl=''})
  -- vim.fn.sign_define('DapBreakpointRejected', {text='❌', texthl='', linehl=configs.colors.dark3, numhl=''})

  -- local function dap_debug_test()
  --   dap_go.debug_test()
  -- end

  -- dap_go.setup()
  -- dap_virtual_text.setup()
  -- dap_ui.setup()

  -- n('<LEADER>drt', dap_debug_test)
  -- n('<LEADER>drf', dap.continue)

  -- n('<LEADER>dc', dap.continue)

  -- n('<LEADER>dx', dap.close)

  -- n('<LEADER>dn', dap.step_over)
  -- n('<LEADER>di', dap.step_into)
  -- n('<LEADER>do', dap.step_out)

  -- n('<LEADER>dbb', dap.toggle_breakpoint)

  -- n('<LEADER>dbc', function ()
  --   dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
  -- end)

  -- n('<LEADER>dbl', function ()
  --   dap.set_breakpoint(nil, nil, vim.fn.input('log: '))
  -- end)

  -- n('<LEADER>dd', dap_ui.toggle)
end

return M

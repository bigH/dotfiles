-- Design:
-- <C-t> activates terminal - default to vertical split
-- gtt - send line to terminal
-- gt<text-obj> - send to terminal
-- <visual>gt - send to terminal

local map = require('keymapper')

local n = map.n
local v = map.v
local i = map.i

local M = {}

-- need to do <Plug> for these keybindings
function M.setup()
  vim.g.personal_all_terminals = {}
  vim.g.personal_current_active_terminal = false

  vim.cmd [[
    augroup TerminalSettings

      au! TermOpen * if &buftype == 'terminal' |
            \   setlocal nonumber |
            \   setlocal norelativenumber |
            \   setlocal scrolloff=0 |
            \   setlocal sidescrolloff=0 |
            \   tnoremap <silent> <M-h> <C-\><C-n><CMD>wincmd h<CR> |
            \   tnoremap <silent> <M-j> <C-\><C-n><CMD>wincmd j<CR> |
            \   tnoremap <silent> <M-k> <C-\><C-n><CMD>wincmd k<CR> |
            \   tnoremap <silent> <M-l> <C-\><C-n><CMD>wincmd l<CR> |
            \   startinsert |
            \ endif

      au! BufEnter * if &buftype == 'terminal' |
            \   startinsert |
            \ endif

      au! TermOpen * lua require('terminal').register(vim.fn.bufnr())

    augroup END
  ]]

  n('<Plug>TerminalToggle', '<CMD>lua require("terminal").toggle()<CR>')

  v('<Plug>TerminalSendVisualSelection', '<CMD>lua require("terminal").sendVisual()<CR>')
  v('<Plug>TerminalSendOperator', '<CMD>lua require("terminal").sendOperator()<CR>')

  n('<C-t>', '<Plug>TerminalToggle')
  i('<C-t>', '<C-O><Plug>TerminalToggle')

  v('gt', '<Plug>TerminalSendVisualSelection')
  n('gt', '<Plug>TerminalSendOperator')
  n('gtt', 'gt_', { remap = true })
end

function M.toggle()
end

function M.sendVisual()
end

function M.sendOperator()
end

return M

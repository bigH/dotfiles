local map = require('keymapper')

-- local imports
local n = map.n
local v = map.v
local i = map.i
local o = map.o

----------------------------- OFTEN MIS-TYPED ---------------------------------

-- K
n('K', '<NOP>')

-- Q
n('Q', '<NOP>')

-- s|S - i just don't use this
n('s', '<NOP>')
n('S', '<NOP>')

----------------------------- PERSONAL DEFAULTS -------------------------------

-- <CR> == : (silent results in weird UX)
n('<CR>', ':', {silent = false})

-- <SPACE> is also <LEADER>, but `\` is the real <LEADER> for more ubiquitous use
n('<SPACE>', '<LEADER>', {remap = true})

-- <CR> == _
o('<CR>', '_')

-- sane `Y`
n('Y', 'yg_')

-- backspace clears highlighted search
n('<BS>', '<CMD>noh<CR>')

-- write everything with LEADER-LEADER
n('<LEADER><LEADER>', '<CMD>wa<CR>')

----------------------------- TEXT MANIPULATION -------------------------------

-- swap g(j|k) and (j|k)
n('gj', 'j')
n('gk', 'k')
n('j', 'gj')
n('k', 'gk')

-- alt-enter to insert new line in normal mode
n('<M-CR>', 'i<CR><ESC>')

-- support clipboard yank for visual selections
v('<LEADER>y', '"+y')

-- explicit system clipboard yank
n('<LEADER>y', '"+y', {remap = true})
n('<LEADER>yy', '"+y_')
n('<LEADER>Y', '"+y$')

-- yank relative path
n('yp', "<CMD>let @\" = expand('%')<CR>")
n('<LEADER>yp', "<CMD>let @+ = expand('%')<CR>")

-- yank absolute path
n('yP', "<CMD>let @\" = expand('%:p')<CR>")
n('<LEADER>yP', "<CMD>let @+ = expand('%:p')<CR>")

-- Alt BS/Shift-BS
i('<M-BS>', '<C-W>')
i('<M-C-H>', '<C-U>')

-------------------------- INTERESTING USEFUL ONES-----------------------------

-- Map `&` to `:&&`, which preserves all flags and performs the substitute
-- again (faithfully) - `g&` will do the same with a new search (using
-- anything that touches the `@/` register
n('&', '<CMD>&&<CR>')

-- Repeat for visual selection
v('.', ':normal .<CR>')


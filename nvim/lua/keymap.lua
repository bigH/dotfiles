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

-- s|S
n('s', '<NOP>')
n('S', '<NOP>')

----------------------------- PERSONAL DEFAULTS -------------------------------

-- <CR> == : (silent results in weird UX)
n('<CR>', ':', { silent = false })

-- <SPACE> is also <LEADER>, but `\` is the real <LEADER> for more ubiquitous use
n('<SPACE>', '<LEADER>', { remap = true })

-- <CR> == _
o('<CR>', '_')

-- sane `Y`
n('Y', 'yg_')

-- backspace clears highlighted search
n('<BS>', '<CMD>noh<CR>')

-- write everything with LEADER-LEADER
n('<LEADER><LEADER>', '<CMD>wa<CR>')

-- TODO useless since i'm not used to it
-- quit after writing with ZZ
n('ZZ', '<CMD>qa<CR>')

-- TODO useless since i'm not used to it
-- save and quit
n('ZX', '<CMD>wqa<CR>')

----------------------------- WINDOWS & BUFFERS -------------------------------

-- switching buffers
n('H', '<CMD>bprev<CR>')
n('<C-h>', '<CMD>bfirst<CR>')
n('L', '<CMD>bnext<CR>')
n('<C-l>', '<CMD>blast<CR>')

-- switching windows
n('<M-h>', '<CMD>wincmd h<CR>')
i('<M-h>', '<C-O><CMD>wincmd h<CR>')

n('<M-j>', '<CMD>wincmd j<CR>')
i('<M-j>', '<C-O><CMD>wincmd j<CR>')

n('<M-l>', '<CMD>wincmd l<CR>')
i('<M-l>', '<C-O><CMD>wincmd l<CR>')

n('<M-k>', '<CMD>wincmd k<CR>')
i('<M-k>', '<C-O><CMD>wincmd k<CR>')

-- creating windows
n('<M-H>', '<CMD>vsplit<CR><CMD>wincmd h<CR>')
i('<M-H>', '<C-O><CMD>vsplit<CR><C-O><CMD>wincmd h<CR>')

n('<M-J>', '<CMD>split<CR>')
i('<M-J>', '<C-O><CMD>split<CR>')

n('<M-K>', '<CMD>split<CR><CMD>wincmd k<CR>')
i('<M-K>', '<C-O><CMD>split<CR><C-O><CMD>wincmd k<CR>')

n('<M-L>', '<CMD>vsplit<CR>')
i('<M-L>', '<C-O><CMD>vsplit<CR>')

----------------------------- TEXT MANIPULATION -------------------------------

-- swap g(j|k) and (j|k)
n('gj', 'j')
n('gk', 'k')
n('j', 'gj')
n('k', 'gk')

-- TODO don't reallyuse these...
-- moving lines while editing
-- i('<C-j>', '<ESC><CMD>m .+1<CR>i')
-- i('<C-k>', '<ESC><CMD>m .-2<CR>i')
-- v('<C-j>', ":m '>+1<CR>gv")
-- v('<C-k>', ":m '<-2<CR>gv")

-- alt-enter to insert new line
n('<M-CR>', 'i<CR><ESC>')

-- explicit system clipboard yank
n('<LEADER>y', '"+y', { remap = true })
n('<LEADER>yy', '"+yg_', { remap = true })
n('yp', "<CMD>let @\" = expand('%')<CR>")
n('<LEADER>yp', "<CMD>let @+ = expand('%')<CR>")

-- Alt BS/Shift-BS
i('<M-BS>', '<C-W>')
i('<M-C-H>', '<C-U>')

-- ????


-------------------------- INTERESTING USEFUL ONES-----------------------------

-- Map `&` to `:&&`, which preserves all flags and performs the substitute
-- again (faithfully) - `g&` will do the same with a new search (using
-- anything that touches the `@/` register
n('&', '<CMD>&&<CR>')

-- Repeat for visual selection
v('.', ':normal .<CR>')

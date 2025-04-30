local map = require('keymapper')

-- local imports
local n = map.n
local v = map.v
local i = map.i
local o = map.o

----------------------------- WINDOWS & BUFFERS -------------------------------

-- switching buffers
n('H', '<CMD>BufferPrevious<CR>')
n('L', '<CMD>BufferNext<CR>')

-- switching buffers in terminal
n('<C-h>', '<CMD>BufferGoto 1<CR>')
n('<C-l>', '<CMD>BufferLast<CR>')

-- switching to numbered buffers
n('<M-1>', '<CMD>BufferGoto 1<CR>')
n('<M-2>', '<CMD>BufferGoto 2<CR>')
n('<M-3>', '<CMD>BufferGoto 3<CR>')
n('<M-4>', '<CMD>BufferGoto 4<CR>')
n('<M-5>', '<CMD>BufferGoto 5<CR>')
n('<M-6>', '<CMD>BufferGoto 6<CR>')
n('<M-7>', '<CMD>BufferGoto 7<CR>')
n('<M-8>', '<CMD>BufferGoto 8<CR>')
n('<M-9>', '<CMD>BufferLast<CR>')
n('<M-0>', '<CMD>BufferPin<CR>')

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

n('<leader>=',
  ':exe "vertical resize " . (max([winwidth(0) + 1, winwidth(0) * 5/4]))<CR>')
n('<leader>-',
  ':exe "vertical resize " . (min([winwidth(0) - 1, winwidth(0) * 4/5]))<CR>')

n('<leader>+',
  ':exe "resize " . max([winheight(0) + 1, winheight(0) * 5/4])<CR>')
n('<leader>_',
  ':exe "resize " . min([winheight(0) - 1, winheight(0) * 4/5])<CR>')


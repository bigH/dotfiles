local M = {}

-- sane default w/ silent and noremap
local default_opts = { noremap = true, silent = true }

-- NB: so far, we don't use outer_opts
local function bind(op, outer_opts)
  local bound_opts = vim.tbl_extend('force', default_opts, outer_opts or {})
  return function(lhs, rhs, provided_opts)
    local opts = vim.tbl_extend('force', bound_opts, provided_opts or {})
    vim.keymap.set(op, lhs, rhs, opts)
  end
end

-- normal mode
M.n = bind('n')
-- visual mode
M.v = bind('v')
-- command mode
M.c = bind('c')
-- insert mode
M.i = bind('i')
-- 
M.x = bind('x')
M.o = bind('o')

return M

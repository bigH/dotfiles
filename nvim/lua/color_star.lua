local configs = require('configs')
local map = require('keymapper')

local n = map.n
local v = map.v

vim.api.nvim_set_hl(0, "ColorStarRed"   , { fg = configs.colors.fg, bg = configs.colors.red })
vim.api.nvim_set_hl(0, "ColorStarYellow", { fg = configs.colors.fg, bg = configs.colors.yellow })
vim.api.nvim_set_hl(0, "ColorStarBlue"  , { fg = configs.colors.fg, bg = configs.colors.blue })
vim.api.nvim_set_hl(0, "ColorStarOrange", { fg = configs.colors.fg, bg = configs.colors.orange })
vim.api.nvim_set_hl(0, "ColorStarGreen" , { fg = configs.colors.fg, bg = configs.colors.green })
vim.api.nvim_set_hl(0, "ColorStarViolet", { fg = configs.colors.fg, bg = configs.colors.violet })

-- n('*', function()
-- end)

-- v('*', function()
-- end)

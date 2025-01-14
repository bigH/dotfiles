local M = {}

local configs = require('configs')
local map = require('keymapper')

local n = map.n
local v = map.v

local highlight_group_names = {
    "ColorStarRed", "ColorStarYellow", "ColorStarBlue", "ColorStarOrange",
    "ColorStarGreen", "ColorStarViolet"
}

vim.g.color_star_state = {}

local function get_visual_selection()
    local vstart = vim.fn.getpos("'<")
    local vend = vim.fn.getpos("'>")

    local num_lines = math.abs(vend[2] - vstart[2]) + 1
    local lines = vim.api.nvim_buf_get_lines(0, vstart[2] - 1, vend[2], false)
    lines[1] = string.sub(lines[1], vstart[3], -1)
    if num_lines == 1 then
        lines[num_lines] = string.sub(lines[num_lines], 1,
                                      vend[3] - vstart[3] + 1)
    else
        lines[num_lines] = string.sub(lines[num_lines], 1, vend[3])
    end

    return table.concat(lines, '\n')
end

local function update_search() end

local function highlight_fixup()
    local new_highlight_index = #vim.g.color_star_state
    local highlight_terms = vim.g.color_star_state[new_highlight_index]
    local highlight_group = highlight_group_names[new_highlight_index]

    -- TODO
end

local function trigger_backspace()
    if #vim.g.color_star_state == 0 then return end

    local last = vim.g.color_star_state[#vim.g.color_star_state]
    if #last == 1 then
        table.remove(vim.g.color_star_state)
    else
        table.remove(last)
    end

    highlight_fixup()
    update_search()
end

local function trigger_color_star(contents)
    table.insert(vim.g.color_star_state, {contents})
    highlight_fixup()
    update_search()
end

local function trigger_color_hash(contents)
    if #vim.g.color_star_state == 0 then
        trigger_color_star(contents)
    else
        local last = vim.g.color_star_state[#vim.g.color_star_state]
        table.insert(last, contents)
    end
    highlight_fixup()
    update_search()
end

function M.actual_setup()
    vim.api.nvim_set_hl(0, "ColorStarRed",
                        {fg = configs.colors.fg, bg = configs.colors.red})
    vim.api.nvim_set_hl(0, "ColorStarYellow",
                        {fg = configs.colors.fg, bg = configs.colors.yellow})
    vim.api.nvim_set_hl(0, "ColorStarBlue",
                        {fg = configs.colors.fg, bg = configs.colors.blue})
    vim.api.nvim_set_hl(0, "ColorStarOrange",
                        {fg = configs.colors.fg, bg = configs.colors.orange})
    vim.api.nvim_set_hl(0, "ColorStarGreen",
                        {fg = configs.colors.fg, bg = configs.colors.green})
    vim.api.nvim_set_hl(0, "ColorStarViolet",
                        {fg = configs.colors.fg, bg = configs.colors.purple})

    -- TODO <BS> to remove last highlight

    n('<BS>', function() trigger_backspace() end)

    n('*', function() trigger_color_star(vim.fn.expand('<cword>')) end)

    n('#', function() trigger_color_hash(vim.fn.expand('<cword>')) end)

    v('*', function()
        local contents = get_visual_selection()
        trigger_color_star(contents)
    end)

    v('#', function()
        local contents = get_visual_selection()
        trigger_color_hash(contents)
    end)
end

function M.setup()
    -- M.actual_setup()
end

return M

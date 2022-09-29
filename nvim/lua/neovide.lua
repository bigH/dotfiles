local map = require('keymapper')

local n = map.n

local M = {}

function M.setup()
  vim.o.guifont = 'Hasklug Nerd Font:h15'

  vim.g.neovide_fullscreen = true
  vim.g.neovide_floating_blur_amount_x = 2.0
  vim.g.neovide_floating_blur_amount_y = 2.0
  vim.g.neovide_remember_window_size = true
  vim.g.neovide_input_use_logo = true
  vim.g.neovide_input_macos_alt_is_meta = true
  vim.g.neovide_cursor_animation_length = 0.02
  vim.g.neovide_cursor_trail_length = 0.2
  vim.g.neovide_cursor_vfx_mode = 'railgun'
  vim.g.neovide_cursor_vfx_opacity = 50.0
  vim.g.neovide_cursor_vfx_particle_density = 30.0
  vim.g.neovide_cursor_vfx_particle_lifetime = 0.8
  vim.g.neovide_cursor_vfx_particle_speed = 20.0
  vim.g.neovide_cursor_vfx_particle_phase = 10.0
  vim.g.neovide_cursor_vfx_particle_curl = 10.0

  vim.g.neovide_profiler = false

  n('<F5>', '<CMD>lua require("neovide").toggleProfiler()<CR>')
end

function M.toggleProfiler()
  if vim.g.neovide_profiler then
    vim.cmd [[
      let g:neovide_profiler = v:false
    ]]
  else
    vim.cmd [[
      let g:neovide_profiler = v:true
    ]]
  end
end

return M

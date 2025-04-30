require("settings")
require("keymap")

if vim.g.vscode then
  require("keymap-vscode")
else
  require("keymap-cli")
end

require("config.lazy")

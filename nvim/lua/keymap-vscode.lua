local map = require('keymapper')
local vscode = require('vscode')

-- local imports
local n = map.n
local v = map.v
local i = map.i
local o = map.o

local na = function(key, action)
  n(key, function()
    vscode.action(action)
  end)
end

local va = function(key, action)
  v(key, function()
    vscode.action(action)
  end)
end

local ia = function(key, action)
  i(key, function()
    vscode.action(action)
  end)
end

----------------------------- BASICS -------------------------------

-- undo/redo
na('u', 'undo')
na('<C-r>', 'redo')

-- vs code back/forward
na('<C-o>', 'workbench.action.navigateBack')
na('<C-i>', 'workbench.action.navigateForward')

-- use refactoring menu
vim.keymap.set({ "n", "x" }, "<leader>r", function()
  vscode.with_insert(function()
    vscode.action("editor.action.refactor")
  end)
end)

----------------------------- WINDOWS & BUFFERS -------------------------------

na('<LEADER>e', 'workbench.action.quickOpen')
va('<LEADER>e', 'workbench.action.quickOpen')

na('<LEADER>f', 'workbench.action.findInFiles')
va('<LEADER>f', 'workbench.action.findInFiles')

na('H', 'workbench.action.previousEditorInGroup')
na('L', 'workbench.action.nextEditorInGroup')

na('<C-h>', 'workbench.action.firstEditorInGroup')
na('<C-l>', 'workbench.action.lastEditorInGroup')

-- -- switching to numbered buffers (done in `keybindings.json`)
-- na('<M-1>', 'workbench.action.openEditorAtIndex1')
-- na('<M-2>', 'workbench.action.openEditorAtIndex2')
-- na('<M-3>', 'workbench.action.openEditorAtIndex3')
-- na('<M-4>', 'workbench.action.openEditorAtIndex4')
-- na('<M-5>', 'workbench.action.openEditorAtIndex5')
-- na('<M-6>', 'workbench.action.openEditorAtIndex6')
-- na('<M-7>', 'workbench.action.openEditorAtIndex7')
-- na('<M-8>', 'workbench.action.openEditorAtIndex8')
-- na('<M-9>', 'workbench.action.lastEditorInGroup')

-- -- switching windows (done in `keybindings.json`)
-- na('<M-h>', 'workbench.action.focusLeftGroup')
-- na('<M-j>', 'workbench.action.focusBelowGroup')
-- na('<M-k>', 'workbench.action.focusAboveGroup')
-- na('<M-l>', 'workbench.action.focusRightGroup')

-- -- switching windows (done in `keybindings.json`)
-- na('<M-H>', 'workbench.action.splitEditorLeft')
-- na('<M-J>', 'workbench.action.splitEditorDown')
-- na('<M-K>', 'workbench.action.splitEditorUp')
-- na('<M-L>', 'workbench.action.splitEditorRight')

-- resize windows
na('<leader>=', 'workbench.action.increaseViewWidth')
na('<leader>-', 'workbench.action.decreaseViewWidth')
na('<leader>+', 'workbench.action.increaseViewHeight')
na('<leader>_', 'workbench.action.decreaseViewHeight')

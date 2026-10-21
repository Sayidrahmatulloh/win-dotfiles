local vscode = require("vscode")
local opts = { noremap = true, silent = true }

require("vscode_nvim.keymaps.editor").setup(vscode)
for _, mapping in ipairs(require("vscode_nvim.keymaps.commands")) do
  local mode, key, command = unpack(mapping)
  vim.keymap.set(mode, key, function()
    vscode.action(command)
  end, opts)
end

require("shared.workflow").setup(function(_, command)
  return function()
    vscode.action(command)
  end
end)

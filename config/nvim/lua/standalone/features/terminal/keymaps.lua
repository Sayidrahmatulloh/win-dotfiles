local map = require("shared.keymap")
local M = {}

function M.attach(term, focus_editor)
  local options = { buffer = term.bufnr }
  -- Escape reaches PowerShell's Vi mode; Ctrl+g enters Neovim Normal mode.
  map("t", "<C-g>", [[<C-\><C-n>]], "Neovim terminal Normal mode", options)
  map("n", "<Esc>", function()
    term:close()
  end, "Hide terminal", options)
  map({ "n", "t" }, "<C-k>", focus_editor, "Return to editor", options)
end

return M

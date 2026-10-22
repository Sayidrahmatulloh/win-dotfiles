local map = require("shared.keymap")
local M = {}

function M.attach(term, focus_editor)
  local options = { buffer = term.bufnr }
  map({ "n", "t" }, "<C-w>", function()
    term:shutdown()
  end, "Kill terminal session", options)
  -- A single Escape reaches the shell; double Escape hides the panel.
  map("t", "<Esc><Esc>", function()
    term:close()
  end, "Hide terminal", options)
  map("t", "<C-g>", [[<C-\><C-n>]], "Neovim terminal Normal mode", options)
  map("n", "<Esc>", function()
    term:close()
  end, "Hide terminal", options)
  map({ "n", "t" }, "<C-k>", focus_editor, "Return to editor", options)
end

return M

local map = require("shared.keymap")
local M = {}

function M.setup()
  map("i", "jk", "<Esc>", "Normal mode")
  map("i", "kj", "<Esc>", "Normal mode")

  map("x", "p", '"_dP', "Paste without replacing clipboard")

  map({ "n", "x" }, "gh", "^", "First non-blank character")
  map({ "n", "x" }, "gl", "$", "End of line")

  map("n", "<Esc>", "<cmd>nohlsearch<cr>", "Clear search highlight")

  map({ "n", "x" }, "<localleader>,", "<cmd>write<cr>", "Save file")
  map("n", "gn", "<cmd>bnext<cr>", "Next buffer")
  map("n", "gp", "<cmd>bprevious<cr>", "Previous buffer")
  -- j/k and Shift+h/l already have the desired LazyVim mappings.
end

return M

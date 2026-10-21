local map = require("shared.keymap")
local M = {}

function M.setup()
  map("n", "<leader>cf", function()
    Snacks.bufdelete()
  end, "Close buffer")

  map("n", "<leader><leader>", function()
    Snacks.picker.files()
  end, "Find files")
  map("n", "<leader>fg", function()
    Snacks.picker.grep()
  end, "Search project")
  map("n", "<leader>fb", function()
    Snacks.picker.buffers()
  end, "Buffers")
  map("n", "<leader>rl", function()
    Snacks.picker.recent()
  end, "Recent files")
  map("n", "<leader>sa", function()
    Snacks.picker.commands()
  end, "Commands")
  map("n", "<leader>pr", function()
    Snacks.picker.diagnostics()
  end, "Project diagnostics")
  map("n", "<leader>vd", vim.diagnostic.open_float, "Line diagnostics")
  map("n", "<leader>re", vim.lsp.buf.rename, "Rename symbol")
  map({ "n", "x" }, "<leader>qf", vim.lsp.buf.code_action, "Code actions")
  map("n", "<leader>vh", vim.lsp.buf.hover, "Documentation")
  map({ "n", "x" }, "<leader>fm", function()
    LazyVim.format({ force = true })
  end, "Format")
  map("n", "<leader>ui", function()
    local visible = vim.o.winbar == ""
    vim.o.winbar = visible and require("standalone.ui.winbar").expression or ""
  end, "Toggle file information above editor")
  map("n", "<leader>ud", function()
    local enabled = vim.diagnostic.config().virtual_text
    vim.diagnostic.config({ virtual_text = not enabled, underline = not enabled })
  end, "Toggle diagnostic annotations")
end

return M

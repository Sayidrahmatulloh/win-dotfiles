-- Shared aliases: preserve the user's existing mappings in both environments.
local M = {}
function M.setup()
  local vscode = vim.g.vscode and require("vscode") or nil
  local function bind(key, command, action, desc, mode)
    vim.keymap.set(mode or "n", "<leader>" .. key, vscode and function()
      vscode.action(command)
    end or action, { silent = true, desc = desc })
  end
  bind("fo", "workbench.action.quickOpen", function() Snacks.picker.files() end, "Find files")
  bind("fs", "workbench.action.files.save", "<cmd>write<cr>", "Save file", { "n", "x" })
  bind("fn", "workbench.action.files.newUntitledFile", "<cmd>enew<cr>", "New file")
  bind("fl", "workbench.action.openRecent", function() Snacks.picker.recent() end, "Recent files")
  bind("fe", "workbench.view.explorer", function() Snacks.explorer() end, "File explorer")
  bind("sp", "workbench.action.findInFiles", function() Snacks.picker.grep() end, "Search project")
  bind("sy", "workbench.action.gotoSymbol", function() Snacks.picker.lsp_symbols() end, "Document symbols")
  bind("sx", "workbench.actions.view.problems", function() Snacks.picker.diagnostics() end, "Project diagnostics")
  bind("cn", "editor.action.rename", vim.lsp.buf.rename, "Rename symbol")
  bind("ca", "editor.action.quickFix", vim.lsp.buf.code_action, "Code action", { "n", "x" })
  bind("cF", "editor.action.formatDocument", function() LazyVim.format({ force = true }) end, "Format", { "n", "x" })
  bind("bs", "workbench.action.showAllEditors", function() Snacks.picker.buffers() end, "Select buffer")
  bind("bd", "workbench.action.closeActiveEditor", function() Snacks.bufdelete() end, "Close buffer")
  bind("bn", "workbench.action.nextEditor", "<cmd>bnext<cr>", "Next buffer")
  bind("bp", "workbench.action.previousEditor", "<cmd>bprevious<cr>", "Previous buffer")
  bind("wv", "workbench.action.splitEditor", "<cmd>vsplit<cr>", "Split vertically")
  bind("wh", "workbench.action.splitEditorDown", "<cmd>split<cr>", "Split horizontally")
  bind("wd", "workbench.action.closeGroup", "<cmd>close<cr>", "Close window")
  bind("w=", "workbench.action.evenEditorWidths", "<C-w>=", "Balance windows")
  bind("wj", "workbench.action.focusBelowGroup", "<C-w>j", "Focus below")
  bind("wK", "workbench.action.focusAboveGroup", "<C-w>k", "Focus above")
end
return M

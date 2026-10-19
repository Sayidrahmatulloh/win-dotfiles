local M = {}

local mappings = {
  { "fo", "workbench.action.quickOpen", "Find files" },
  { "fs", "workbench.action.files.save", "Save file", { "n", "x" } },
  { "fn", "workbench.action.files.newUntitledFile", "New file" },
  { "fl", "workbench.action.openRecent", "Recent files" },
  { "fe", "workbench.view.explorer", "Open or focus sidebar" },
  { "sd", "workbench.action.increaseViewSize", "Increase sidebar size" },
  { "si", "workbench.action.decreaseViewSize", "Decrease sidebar size" },
  { "sp", "workbench.action.findInFiles", "Search project" },
  { "sy", "workbench.action.gotoSymbol", "Document symbols" },
  { "sx", "workbench.actions.view.problems", "Project diagnostics" },
  { "cn", "editor.action.rename", "Rename symbol" },
  { "ca", "editor.action.quickFix", "Code action", { "n", "x" } },
  { "cF", "editor.action.formatDocument", "Format", { "n", "x" } },
  { "bs", "workbench.action.showAllEditors", "Select buffer" },
  { "bd", "workbench.action.closeActiveEditor", "Close buffer" },
  { "bn", "workbench.action.nextEditor", "Next buffer" },
  { "bp", "workbench.action.previousEditor", "Previous buffer" },
  { "wv", "workbench.action.splitEditor", "Split vertically" },
  { "wh", "workbench.action.splitEditorDown", "Split horizontally" },
  { "wd", "workbench.action.closeGroup", "Close window" },
  { "w=", "workbench.action.evenEditorWidths", "Balance windows" },
  { "wj", "workbench.action.focusBelowGroup", "Focus below" },
  { "wK", "workbench.action.focusAboveGroup", "Focus above" },
}

-- Each environment supplies its own actions; shared code never loads either one.
function M.setup(resolve_action)
  for _, mapping in ipairs(mappings) do
    local key, command, description, mode = unpack(mapping)
    local action = assert(resolve_action(key, command), "Missing workflow action: " .. key)
    vim.keymap.set(mode or "n", "<leader>" .. key, action, { silent = true, desc = description })
  end
end

return M

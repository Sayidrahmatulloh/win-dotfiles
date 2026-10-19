local M = {}

function M.apply(win, name, normal, border, selection)
  -- A window namespace keeps the surface stable when Snacks updates winhighlight.
  local ns = vim.api.nvim_create_namespace(name)
  local normal_highlight = vim.api.nvim_get_hl(0, { name = normal, link = false })
  for _, group in ipairs({
    "Normal",
    "NormalNC",
    "NormalFloat",
    "EndOfBuffer",
    "SnacksNormal",
    "SnacksNormalNC",
    "SnacksPicker",
    "SnacksPickerList",
    "SnacksPickerInput",
  }) do
    vim.api.nvim_set_hl(ns, group, normal_highlight)
  end
  vim.api.nvim_set_hl(ns, "FloatBorder", vim.api.nvim_get_hl(0, { name = border, link = false }))
  vim.api.nvim_set_hl(ns, "CursorLine", vim.api.nvim_get_hl(0, { name = selection, link = false }))
  if win:valid() then
    vim.api.nvim_win_set_hl_ns(win.win, ns)
  end
end

return M

local M = {}
M.winbar_expr = "%{%v:lua.require('config.ui').winbar()%}"

function M.winbar()
  if vim.bo.buftype ~= "" then
    return ""
  end
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    return ""
  end
  local name = vim.fs.basename(path):gsub("%%", "%%%%")
  local icon, highlight = "", "WinBar"
  local ok, icons = pcall(require, "mini.icons")
  if ok then
    icon, highlight = icons.get("file", path)
  end
  return "%#" .. highlight .. "# " .. icon .. " %#WinBar# " .. name .. (vim.bo.modified and " [+]" or "")
end

function M.explorer_on_show(picker)
  -- Snacks has no totals toggle: suppress its counter for this explorer instance.
  local input = picker.input
  if input._without_totals then
    return
  end
  input._without_totals = true
  local update = input.update
  local ns = vim.api.nvim_create_namespace("snacks.picker.input")
  local function clear_totals()
    if input.win:valid() then
      vim.api.nvim_buf_del_extmark(input.win.buf, ns, 999)
    end
  end
  input.update = function(self)
    update(self)
    clear_totals()
  end
  clear_totals()
end

function M.open_explorer()
  local filewin = vim.api.nvim_get_current_win()
  local cwd = LazyVim.root()
  return Snacks.explorer({
    cwd = cwd,
    title = vim.fs.basename(cwd),
    on_show = function(picker)
      M.explorer_on_show(picker)
      -- Leave the file ready for typing after the sidebar appears.
      if vim.api.nvim_win_is_valid(filewin) then
        vim.api.nvim_set_current_win(filewin)
      end
    end,
  })
end

return M

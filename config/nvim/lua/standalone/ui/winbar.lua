local M = {}
M.expression = "%{%v:lua.require('standalone.ui.winbar').render()%}"

function M.render()
  if vim.bo.buftype ~= "" then
    return ""
  end
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    return ""
  end
  local name = vim.fs.basename(path):gsub("%%", "%%%%")
  local relative = vim.fn.fnamemodify(path, ":~:."):gsub("\\", "/")
  local parent = vim.fs.dirname(relative)
  local context = parent and parent ~= "." and ("  %#WinBarPath#" .. parent:gsub("%%", "%%%%")) or ""
  local icon, highlight = "", "WinBar"
  local ok, icons = pcall(require, "mini.icons")
  if ok then
    icon, highlight = icons.get("file", path)
  end
  return "%#" .. highlight .. "# " .. icon .. " %#WinBar# " .. name .. (vim.bo.modified and " [+]" or "") .. context
end

return M

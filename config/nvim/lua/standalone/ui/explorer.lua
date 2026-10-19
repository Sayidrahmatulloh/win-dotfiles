local M = {}
local surface = require("standalone.ui.surface")
local picker_ui = require("standalone.ui.picker")

function M.focus()
  for _, picker in ipairs(Snacks.picker.get({ source = "explorer" })) do
    picker:focus("list")
    return
  end
  Snacks.explorer({ focus = "list" })
end

function M.on_show(picker)
  local ns = vim.api.nvim_create_namespace("desktop.explorer")
  for _, group in ipairs({
    "SnacksPickerFile",
    "SnacksPickerDirectory",
    "SnacksPickerPathHidden",
    "SnacksPickerPathIgnored",
  }) do
    local highlight = vim.api.nvim_get_hl(0, { name = group, link = false })
    highlight.italic = true
    vim.api.nvim_set_hl(ns, group, highlight)
  end
  -- Give the sidebar its own surface without recoloring other pickers.
  local sidebar = "Normal:ExplorerNormal,NormalNC:ExplorerNormal,EndOfBuffer:ExplorerNormal,"
    .. "CursorLine:ExplorerSelection,WinBar:ExplorerTitle,WinBarNC:ExplorerTitle,"
    .. "FloatBorder:ExplorerBorder,WinSeparator:ExplorerBorder"
  for _, win in ipairs({ picker.input.win, picker.list.win }) do
    win.opts.wo.winhighlight = sidebar
    if win:valid() then
      vim.wo[win.win].winhighlight = sidebar
    end
    surface.apply(win, "desktop.explorer", "ExplorerNormal", "ExplorerBorder", "ExplorerSelection")
  end
  if picker.list.win:valid() then
    local title = vim.fs.basename(picker:cwd()):gsub("%%", "%%%%")
    picker.list.win.opts.wo.winbar = "%#ExplorerTitle# " .. title
    vim.wo[picker.list.win.win].winbar = picker.list.win.opts.wo.winbar
  end
  picker_ui.hide_totals(picker)
end

function M.resize(amount)
  for _, picker in ipairs(Snacks.picker.get({ source = "explorer" })) do
    local layout = picker.layout
    if layout and layout.root:valid() then
      local win = layout.root.win
      local max_width = math.max(1, vim.o.columns - 27)
      local min_width = math.min(26, max_width)
      local width = vim.api.nvim_win_get_width(win) + amount
      vim.api.nvim_win_set_width(win, math.max(min_width, math.min(max_width, width)))
      layout:update()
      return
    end
  end
end

function M.open()
  local directory = vim.api.nvim_buf_get_name(0)
  local is_directory = directory ~= "" and vim.fn.isdirectory(directory) == 1
  local cwd = is_directory and vim.fs.normalize(directory) or LazyVim.root()
  if is_directory then
    -- `nvim .` leaves an empty directory buffer when Netrw is disabled.
    -- Keep the main editor ready for a file, and browse only in the sidebar.
    local directory_buf = vim.api.nvim_get_current_buf()
    vim.cmd.enew()
    vim.api.nvim_buf_delete(directory_buf, { force = false })
  end
  local filewin = vim.api.nvim_get_current_win()
  return Snacks.explorer({
    cwd = cwd,
    title = vim.fs.basename(cwd),
    on_show = function(picker)
      M.on_show(picker)
      -- Leave the file ready for typing after the sidebar appears.
      if vim.api.nvim_win_is_valid(filewin) then
        vim.api.nvim_set_current_win(filewin)
      end
    end,
  })
end

return M

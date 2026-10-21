local M = {}
local surface = require("standalone.ui.surface")

function M.hide_totals(picker)
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
      if picker.opts.layout.preset == "quick_open" then
        local placeholder_ns = vim.api.nvim_create_namespace("desktop.quick_open.placeholder")
        vim.api.nvim_buf_clear_namespace(input.win.buf, placeholder_ns, 0, -1)
        if input:get() == "" then
          local hint = "Search files by name"
          vim.api.nvim_buf_set_extmark(input.win.buf, placeholder_ns, 0, 0, {
            virt_text = { { hint, "QuickOpenPlaceholder" } },
            virt_text_pos = "overlay",
            hl_mode = "replace",
          })
        end
      end
    end
  end
  input.update = function(self)
    update(self)
    clear_totals()
  end
  clear_totals()
end

function M.format_file(item, picker)
  -- Let Snacks retain file matching and icon highlights; put context at the right.
  local result = Snacks.picker.format.filename(item, picker)
  if not item.file then
    return result
  end
  local path = Snacks.picker.util.path(item) or vim.fs.normalize(item.file)
  local relative = vim.fs.relpath(picker:cwd(), path) or path
  local parent = vim.fs.dirname(relative)
  if not parent or parent == "." then
    return result
  end
  local list_width = picker.list.win:dim().width
  local available = list_width - vim.fn.strdisplaywidth(vim.fs.basename(path)) - 6
  local width = math.min(available, math.floor(list_width * 0.45))
  if width < 4 then
    return result
  end
  if vim.fn.strchars(parent) > width then
    parent = "…" .. vim.fn.strcharpart(parent, vim.fn.strchars(parent) - width + 1)
  end
  if vim.fn.has("win32") == 1 then
    parent = parent:gsub("/", "\\")
  end
  result[#result + 1] = {
    col = 0,
    virt_text = { { parent .. " ", "SnacksPickerDir" } },
    virt_text_pos = "right_align",
    hl_mode = "combine",
  }
  return result
end

function M.on_show(picker)
  for _, entry in ipairs({
    { picker.input.win, "QuickOpenInput", "QuickOpenBorder" },
    { picker.list.win, "QuickOpenNormal", "QuickOpenNormal" },
  }) do
    local win = entry[1]
    local highlights = "Normal:"
      .. entry[2]
      .. ",NormalNC:"
      .. entry[2]
      .. ",FloatBorder:"
      .. entry[3]
      .. ",CursorLine:QuickOpenSelection"
    win.opts.wo.winhighlight = highlights
    if win:valid() then
      vim.wo[win.win].winhighlight = highlights
    end
    surface.apply(win, "desktop." .. entry[2], entry[2], entry[3], "QuickOpenSelection")
  end
  M.hide_totals(picker)
end

return M

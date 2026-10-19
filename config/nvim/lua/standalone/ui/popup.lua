local M = {}
local CMDLINE_VIEWS = { "cmdline_popup", "cmdline_input" }
M.border = "rounded"
M.width = 0.50
M.min_width = 32
M.max_width = 90

function M.geometry()
  local width = math.min(math.max(math.floor(vim.o.columns * M.width), M.min_width), M.max_width, vim.o.columns - 4)
  return {
    width = width,
    row = math.floor((vim.o.lines - vim.o.cmdheight) * 0.25),
    col = math.floor((vim.o.columns - width) / 2),
  }
end

function M.search_layout(layout)
  local box = M.geometry()
  layout.layout.width = box.width
  layout.layout.min_width = math.min(M.min_width, box.width)
  layout.layout.max_width = box.width
  layout.layout.row = box.row
  layout.layout.col = box.col
  return layout
end

function M.input()
  local function width()
    return math.min(M.geometry().width - 2, 50)
  end
  return {
    relative = "editor",
    width = width,
    height = 1,
    row = function()
      return M.geometry().row
    end,
    col = function()
      return math.floor((vim.o.columns - width() - 2) / 2)
    end,
    border = M.border,
    wo = { winbar = "" },
  }
end

function M.cmdline()
  local box = M.geometry()
  return {
    relative = "editor",
    -- NUI positions the content; Snacks positions the outer native border.
    -- Offset by one cell so the visible rounded borders share the same origin.
    position = { row = box.row + 1, col = box.col + 1 },
    size = { width = box.width - 2, min_width = box.width - 2, height = 1 },
    border = { style = vim.deepcopy(M.border), padding = { 0, 0 }, text = { top = "" } },
    win_options = { winbar = "", winhighlight = { Normal = "QuickOpenInput", FloatBorder = "QuickOpenBorder" } },
  }
end

function M.configure_noice(opts)
  opts.views = opts.views or {}
  for _, view in ipairs(CMDLINE_VIEWS) do
    opts.views[view] = vim.tbl_deep_extend("force", opts.views[view] or {}, M.cmdline())
  end
  opts.cmdline = opts.cmdline or {}
  opts.cmdline.opts = { border = { text = { top = "" } } }
  local group = vim.api.nvim_create_augroup("desktop_popup_geometry", { clear = true })
  vim.api.nvim_create_autocmd({ "VimResized", "CmdlineEnter" }, {
    group = group,
    callback = function()
      local config = require("noice.config").options
      for _, view in ipairs(CMDLINE_VIEWS) do
        config.views[view] = vim.tbl_deep_extend("force", config.views[view], M.cmdline())
      end
    end,
  })
end

return M

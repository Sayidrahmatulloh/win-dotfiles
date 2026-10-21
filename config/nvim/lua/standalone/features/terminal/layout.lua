local M = {}
local maximized = false

local function available_height()
  return vim.o.lines - vim.o.cmdheight - (vim.o.laststatus == 0 and 0 or 1)
end

function M.height()
  local available = available_height()
  if maximized then
    return math.max(1, available - 2)
  end
  return math.max(1, math.min(16, math.floor(available * 0.30)))
end

function M.width()
  return math.max(1, vim.o.columns - 4)
end

function M.row()
  return math.max(0, available_height() - M.height() - 2)
end

function M.toggle()
  maximized = not maximized
end

function M.geometry()
  return { relative = "editor", row = M.row(), col = 1, width = M.width(), height = M.height() }
end

function M.options()
  return { border = "curved", width = M.width, height = M.height, row = M.row, col = 1, winblend = 0 }
end

return M

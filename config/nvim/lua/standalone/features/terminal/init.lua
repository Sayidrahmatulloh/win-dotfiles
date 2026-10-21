local M = {}
local active_id, editor_win
local layout = require("standalone.features.terminal.layout")

local function terminals()
  return require("toggleterm.terminal")
end

local function remember_editor()
  if vim.bo.buftype == "" then
    editor_win = vim.api.nvim_get_current_win()
  end
end

local function hide_all()
  for _, term in ipairs(terminals().get_all()) do
    if term:is_open() then
      term:close()
    end
  end
end

local function show(term)
  remember_editor()
  hide_all()
  active_id = term.id
  term:open(layout.height(), "float")
  vim.cmd.startinsert()
end

function M.new()
  local term = terminals().Terminal:new({
    dir = LazyVim.root(),
    direction = "float",
    close_on_exit = true,
  })
  term.display_name = "PowerShell #" .. term.id
  show(term)
end

function M.toggle()
  remember_editor()
  for _, term in ipairs(terminals().get_all()) do
    if term:is_open() then
      active_id = term.id
      hide_all()
      return
    end
  end
  local term = active_id and terminals().get(active_id)
  term = term or terminals().get_all()[1]
  if term then
    show(term)
  else
    M.new()
  end
end

function M.maximize()
  layout.toggle()
  for _, term in ipairs(terminals().get_all()) do
    if term:is_open() then
      vim.api.nvim_win_set_config(term.window, layout.geometry())
      return
    end
  end
  M.toggle()
end

function M.switch(id)
  local term = terminals().get(id)
  if not term then
    vim.notify("Terminal #" .. id .. " is not open yet. Press Space tn to create it.", vim.log.levels.INFO)
    return
  end
  if term:is_open() then
    vim.api.nvim_set_current_win(term.window)
    vim.cmd.startinsert()
    return
  end
  show(term)
end

function M.select()
  remember_editor()
  local items = terminals().get_all()
  if #items == 0 then
    M.new()
    return
  end
  vim.ui.select(items, {
    prompt = "Terminals",
    format_item = function(term)
      return (term.display_name or ("Terminal #" .. term.id))
        .. (term.id == active_id and " (active)" or "")
    end,
  }, function(term)
    if term then
      show(term)
    end
  end)
end

function M.editor()
  vim.cmd.stopinsert()
  local function is_editor(win)
    return vim.api.nvim_win_is_valid(win)
      and vim.api.nvim_win_get_config(win).relative == ""
      and vim.bo[vim.api.nvim_win_get_buf(win)].buftype == ""
  end
  if editor_win and is_editor(editor_win) then
    vim.api.nvim_set_current_win(editor_win)
    return
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_editor(win) then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
end

function M.on_open(term)
  active_id = term.id
  local wo = vim.wo[term.window]
  wo.winbar, wo.number, wo.relativenumber, wo.signcolumn = "", false, false, "no"
  require("standalone.features.terminal.keymaps").attach(term, M.editor)
end

return M

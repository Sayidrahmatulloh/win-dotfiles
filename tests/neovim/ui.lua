-- Exercises actual picker windows using only a temporary directory.
-- nvim --headless -i NONE -n -u config/nvim/init.lua '+luafile tests/neovim/ui.lua' +qa
local fixture, quick_open, sidebar

local function press(key)
  local mapping = vim.fn.maparg(key, "n", false, true)
  assert(type(mapping.callback) == "function", "Missing callback for " .. key)
  mapping.callback()
end

local function check()
  vim.o.columns, vim.o.lines = 140, 45
  vim.cmd.doautocmd("User VeryLazy")
  fixture = vim.fn.tempname():gsub("\\", "/")
  vim.fn.mkdir(fixture .. "/src", "p")
  local file = fixture .. "/src/main%.ts"
  vim.fn.writefile({ "export const value = 1" }, file)
  vim.cmd.lcd(fixture)
  vim.cmd.edit(vim.fn.fnameescape(file))
  local file_win = vim.api.nvim_get_current_win()
  local original_width = vim.api.nvim_win_get_width(file_win)
  local original_height = vim.api.nvim_win_get_height(file_win)
  assert(require("standalone.ui.winbar").render():find("main%%.ts", 1, true), "Winbar did not escape percent signs")

  press("<leader>fe")
  assert(
    vim.wait(5000, function()
      local pickers = Snacks.picker.get({ source = "explorer" })
      sidebar = pickers[1]
      return sidebar and sidebar.list.win:valid()
    end, 20),
    "Sidebar did not open"
  )
  press("<leader>fe")
  assert(#Snacks.picker.get({ source = "explorer" }) == 1, "Sidebar focus opened a duplicate or closed the sidebar")
  assert(vim.api.nvim_get_current_win() == sidebar.list.win.win, "Sidebar did not receive focus")
  local sidebar_header = vim.api.nvim_eval_statusline(vim.wo[sidebar.list.win.win].winbar, {
    winid = sidebar.list.win.win,
    use_winbar = true,
  }).str
  assert(sidebar_header == "", "Sidebar duplicates the project name in a winbar: " .. sidebar_header)
  assert(vim.api.nvim_win_get_config(sidebar.layout.root.win).relative == "editor", "Sidebar is not a floating overlay")
  assert(vim.api.nvim_win_get_config(sidebar.list.win.win).zindex < 50, "Sidebar would cover the floating terminal")
  assert(vim.api.nvim_win_get_width(file_win) == original_width, "Sidebar resized the editor width")
  assert(vim.api.nvim_win_get_height(file_win) == original_height, "Sidebar resized the editor height")
  local back = vim.fn.maparg("w", "n", false, true)
  assert(type(back.callback) == "function", "Sidebar lost its return-to-editor shortcut")
  back.callback()
  assert(vim.api.nvim_get_current_win() == file_win, "Sidebar w did not return to the editor")
  assert(sidebar.list.win:valid(), "Returning to the editor closed the sidebar")

  vim.api.nvim_set_current_win(file_win)
  local sidebar_width = vim.api.nvim_win_get_width(sidebar.layout.root.win)
  press("<leader>sd")
  assert(
    vim.api.nvim_win_get_width(sidebar.layout.root.win) == sidebar_width + 4,
    "Sidebar did not increase by four columns"
  )
  assert(vim.api.nvim_get_current_win() == file_win, "Sidebar resize moved editor focus")
  press("<leader>si")
  assert(vim.api.nvim_win_get_width(sidebar.layout.root.win) == sidebar_width, "Sidebar size was not restored")

  local file_width, file_height = vim.api.nvim_win_get_width(file_win), vim.api.nvim_win_get_height(file_win)
  quick_open = Snacks.picker.files({ cwd = fixture })
  assert(
    vim.wait(5000, function()
      return quick_open.input.win:valid() and not quick_open:is_active()
    end, 20),
    "Quick Open did not open"
  )
  local input = vim.api.nvim_win_get_config(quick_open.input.win.win)
  local cmdline = require("standalone.ui.popup").cmdline()
  assert(input.relative ~= "" and input.height == 1, "Search input is not a single-line float: " .. vim.inspect(input))
  assert(input.border[1] == "╭" and input.border[3] == "╮", "Search input lost its rounded border")
  assert(input.width == cmdline.size.width, "Command line and search have different widths")
  local position = vim.api.nvim_win_get_position(quick_open.input.win.win)
  -- Noice stores the content origin; the native float position includes its border.
  assert(
    position[1] + 1 == cmdline.position.row and position[2] + 1 == cmdline.position.col,
    "Popup origins differ: " .. vim.inspect({ search = position, cmdline = cmdline.position })
  )
  assert(vim.api.nvim_win_get_width(file_win) == file_width, "Quick Open changed the editor width")
  assert(vim.api.nvim_win_get_height(file_win) == file_height, "Quick Open changed the editor height")
  for _, group in ipairs({ "Normal", "QuickOpenNormal", "QuickOpenInput", "ExplorerNormal" }) do
    assert(vim.api.nvim_get_hl(0, { name = group, link = false }).bg == 0x0b1015, "Background changed: " .. group)
  end
  local namespace = vim.api.nvim_get_namespaces()["desktop.explorer"]
  assert(
    vim.api.nvim_get_hl(namespace, { name = "SnacksPickerFile", link = false }).italic,
    "Sidebar text lost italics"
  )
  print("Sidebar focus/resize, escaped winbar, popup alignment, rounded borders and shared backgrounds OK")
end

local ok, err = pcall(check)
if quick_open then
  quick_open:close()
end
if sidebar then
  sidebar:close()
end
if fixture then
  local temp_root = vim.fn.fnamemodify(vim.fn.tempname(), ":h"):gsub("\\", "/")
  assert(fixture:find(temp_root .. "/", 1, true) == 1, "Unexpected fixture cleanup path")
  vim.fn.delete(fixture, "rf")
end
if not ok then
  print(err)
  vim.cmd("cquit 1")
end

-- Real Neovim windows with a fake shell backend: no plugins or child processes.
local root = assert(vim.fs.root(debug.getinfo(1, "S").source:sub(2), "setup.json"), "Repository root not found")
vim.opt.rtp:prepend(root .. "/config/nvim")

local function check()
  vim.o.columns, vim.o.lines, vim.o.laststatus = 120, 40, 3
  local terminal = require("standalone.features.terminal")
  local layout = require("standalone.features.terminal.layout")
  local terms, serial = {}, 0
  local backend = { Terminal = {} }
  function backend.get_all()
    local items = vim.tbl_values(terms)
    table.sort(items, function(a, b)
      return a.id < b.id
    end)
    return items
  end
  function backend.get(id)
    return terms[id]
  end
  function backend.Terminal:new(options)
    serial = serial + 1
    local term = { id = serial, dir = options.dir }
    function term:is_open()
      return self.window ~= nil and vim.api.nvim_win_is_valid(self.window)
    end
    function term:close()
      if self:is_open() then
        vim.api.nvim_win_close(self.window, true)
      end
      self.window = nil
    end
    function term:open(_, direction)
      assert(direction == "float", "Terminal stopped using a floating window")
      if not self.bufnr then
        self.bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, { "saved shell output" })
      end
      self.window = vim.api.nvim_open_win(self.bufnr, true, vim.tbl_extend("force", layout.geometry(), {
        border = "rounded",
      }))
      terms[self.id] = self
      terminal.on_open(self)
    end
    return term
  end
  package.loaded["toggleterm.terminal"] = backend
  LazyVim = { root = function() return root end }
  local editor = vim.api.nvim_get_current_win()
  local editor_width, editor_height = vim.api.nvim_win_get_width(editor), vim.api.nvim_win_get_height(editor)

  terminal.toggle()
  assert(serial == 1 and terms[1]:is_open())
  assert(vim.fn.maparg("<Esc>", "t") == "", "Escape no longer reaches PowerShell Vi mode")
  assert(vim.fn.maparg("<C-g>", "t") ~= "", "Missing Neovim Normal-mode shortcut")
  assert(vim.fn.maparg("<Esc>", "n") ~= "", "Normal-mode Escape no longer hides the terminal")
  terminal.editor()
  assert(vim.api.nvim_get_current_win() == editor, "Editor focus was not restored")
  terminal.toggle()
  assert(not terms[1]:is_open(), "Toggle did not hide the terminal")
  terminal.toggle()
  assert(serial == 1, "Reopening created a new shell")
  terminal.new()
  assert(serial == 2 and not terms[1]:is_open() and terms[2]:is_open())
  terminal.switch(1)
  assert(terms[1]:is_open() and not terms[2]:is_open())

  local win, buf = terms[1].window, terms[1].bufnr
  local height = vim.api.nvim_win_get_height(win)
  terminal.maximize()
  assert(vim.api.nvim_win_get_height(win) > height and vim.api.nvim_win_get_config(win).row == 0)
  terminal.maximize()
  assert(vim.api.nvim_win_get_height(win) == height, "Window size was not restored")
  assert(terms[1].window == win and terms[1].bufnr == buf, "Resize replaced the running session")
  assert(vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == "saved shell output")

  vim.ui.select = function(items, _, callback)
    callback(items[2])
  end
  terminal.select()
  assert(terms[2]:is_open() and not terms[1]:is_open(), "Session picker selected the wrong terminal")
  local notice
  vim.notify = function(message) notice = message end
  terminal.switch(3)
  assert(notice and notice:find("not open yet", 1, true), "Missing-session feedback changed")
  terminal.toggle()
  terms[2] = nil -- Simulate the active shell exiting.
  terminal.toggle()
  assert(terms[1]:is_open() and serial == 2, "Exited-session fallback failed")
  assert(vim.api.nvim_win_get_width(editor) == editor_width)
  assert(vim.api.nvim_win_get_height(editor) == editor_height, "Floating terminal resized the editor")
  terms[1]:close()
  print("Terminal: sessions, focus, Vi keymaps, float layout, maximize/restore and exit fallback OK")
end

local ok, err = pcall(check)
if not ok then
  print(err)
  vim.cmd("cquit 1")
end

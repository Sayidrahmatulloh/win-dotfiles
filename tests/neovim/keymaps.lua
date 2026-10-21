-- Run with -u NONE for policy tests, or after init.lua for actual LazyVim keys.
local root = assert(vim.fs.root(debug.getinfo(1, "S").source:sub(2), "setup.json"), "Repository root not found")
vim.opt.rtp:prepend(root .. "/config/nvim")

local function mapping(key, mode)
  return vim.fn.maparg(key, mode or "n", false, true)
end

local function check()
  local defaults = require("standalone.keymaps.defaults")
  local integration = package.loaded["lazyvim.config"] ~= nil
  if integration then
    vim.cmd.doautocmd("User VeryLazy")
  else
    require("shared.options")
    for _, item in ipairs(defaults.core) do
      vim.keymap.set(item[1], item[2], "<Nop>")
    end
    vim.keymap.set("n", "<leader>gg", "<Nop>")
    require("standalone.config.keymaps")
  end

  for _, key in ipairs({ "<leader>cd", "<leader>ft", "<leader>fT", "<leader>-", "<leader>|", "[b", "]b" }) do
    assert(next(mapping(key)) == nil, "Unwanted LazyVim default remains: " .. key)
  end
  assert(next(mapping("<leader>cf", "x")) == nil, "Visual cf still formats while normal cf closes a buffer")
  for _, key in ipairs({ "<leader>fe", "<leader>cf", "<leader>fm", "<leader>fg", "<leader>sa", "<leader>sd", "<leader>si" }) do
    assert(type(mapping(key).callback) == "function", "Personal shortcut was lost: " .. key)
  end
  assert(next(mapping("<leader>gg")) ~= nil, "An unrelated Git shortcut was removed")

  if integration then
    for _, key in ipairs({ "<leader>e", "<leader>E", "<leader>fE", "<leader>ff", "<leader>fr", "<leader>sg", "<leader>sC" }) do
      assert(next(mapping(key)) == nil, "Disabled plugin shortcut was restored: " .. key)
    end
    for _, key in ipairs({ "<leader>tt", "<leader>tn", "<leader>ts", "<leader>tf" }) do
      assert(next(mapping(key)) ~= nil, "Terminal shortcut was lost: " .. key)
    end
    -- Resolve the same merged LSP key specifications used when a server attaches.
    local plugin = require("lazy.core.config").plugins["nvim-lspconfig"]
    local options = require("lazy.core.plugin").values(plugin, "opts", false)
    local keys = require("lazy.core.handler.keys").resolve(options.servers["*"].keys)
    for _, item in pairs(keys) do
      assert(item.lhs ~= "<leader>cr" and item.lhs ~= "<leader>ss", "Duplicate LSP shortcut remains")
    end
  else
    local specs = defaults.plugin_keys("snacks")
    assert(#specs > 0)
    for _, spec in ipairs(specs) do
      assert(spec[2] == false, "Plugin defaults must be disabled at their lazy.nvim source")
    end
  end
  print("Keymaps: personal shortcuts preserved; duplicate defaults disabled; unrelated Git shortcuts retained")
end

local ok, err = pcall(check)
if not ok then
  print(err)
  vim.cmd("cquit 1")
end

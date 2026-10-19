-- No plugins are installed or loaded by this routing regression check.
-- nvim --headless -u NONE -i NONE -n -l tests/nvim-structure.lua standalone
-- nvim --headless -u NONE -i NONE -n -l tests/nvim-structure.lua vscode
local root = vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)))
local config = root .. "/config/nvim"
vim.opt.rtp:prepend(config)

local function check()
  local profile = assert(arg[1], "Choose standalone or vscode")
  assert(profile == "standalone" or profile == "vscode", "Unknown profile: " .. profile)
  local namespace = profile == "vscode" and "vscode_nvim" or "standalone"
  -- Match vscode-neovim's check before it adds its own API to runtimepath.
  local conflicts = vim.api.nvim_get_runtime_file("lua/vscode/", true)
  vim.list_extend(conflicts, vim.api.nvim_get_runtime_file("lua/vscode.lua", true))
  assert(#conflicts == 0, "Configuration shadows the VS Code API: " .. table.concat(conflicts, ", "))
  vim.g.vscode = profile == "vscode" and true or nil
  local setup, command
  package.loaded["shared.bootstrap"] = {
    setup = function(options)
      setup = options
    end,
  }
  if vim.g.vscode then
    package.loaded["vscode"] = {
      action = function(action)
        command = action
      end,
    }
  end
  dofile(config .. "/init.lua")
  assert(setup, "Environment did not initialize its plugin manager")
  if profile == "standalone" then
    -- Exercise the exact hook names that LazyVim calls.
    for _, hook in ipairs({ "options", "keymaps", "autocmds" }) do
      require("config." .. hook)
      assert(package.loaded["standalone.config." .. hook], "LazyVim hook did not reach standalone: " .. hook)
    end
    assert(vim.g.loaded_netrwPlugin == 1, "Directory browsing no longer disables Netrw")
  else
    assert(setup.root:match("/lazy%-vscode$"), "VS Code no longer has a separate plugin directory")
    assert(setup.lockfile:match("/lazy%-lock%-vscode%.json$"), "VS Code lockfile changed")
    local sidebar = vim.fn.maparg("<leader>fe", "n", false, true)
    sidebar.callback()
    assert(command == "workbench.view.explorer", "VS Code sidebar mapping reached the wrong editor")
    vim.fn.maparg("<leader>fn", "n", false, true).callback()
    assert(command == "workbench.action.files.newUntitledFile", "Shared new-file action was overridden")
    vim.fn.maparg("<leader>se", "n", false, true).callback()
    assert(command == "workbench.action.quickOpenSelectNext", "Existing quick-open navigation changed")
  end

  local imports, plugins = {}, {}
  local other = profile == "vscode" and "standalone" or "vscode_nvim"
  for _, spec in ipairs(setup.spec) do
    if spec.import and spec.import ~= "lazyvim.plugins" then
      imports[spec.import] = true
      assert(not spec.import:find(other, 1, true), "Environment imports the other profile")
      for _, path in ipairs(vim.fn.glob(config .. "/lua/" .. spec.import:gsub("%.", "/") .. "/*.lua", false, true)) do
        local module = spec.import .. "." .. vim.fs.basename(path):gsub("%.lua$", "")
        local entries = require(module)
        entries = type(entries[1]) == "string" and { entries } or entries
        for _, entry in ipairs(entries) do
          plugins[entry[1]] = true
        end
      end
    end
  end
  assert(imports["shared.plugins"] and imports[namespace .. ".plugins"], "Shared or profile plugins were omitted")
  for _, plugin in ipairs({
    "numToStr/Comment.nvim",
    "tommcdo/vim-exchange",
    "folke/flash.nvim",
    "kylechui/nvim-surround",
    "nvim-telescope/telescope.nvim",
    "johmsalas/text-case.nvim",
    "nvim-treesitter/nvim-treesitter-textobjects",
  }) do
    assert(plugins[plugin], "Shared plugin was lost: " .. plugin)
  end
  if profile == "vscode" then
    assert(plugins["vscode-neovim/vscode-multi-cursor.nvim"], "VS Code multi-cursor was lost")
    assert(not plugins["akinsho/toggleterm.nvim"], "VS Code imported the standalone terminal")
  else
    assert(
      plugins["akinsho/toggleterm.nvim"] and plugins["dont-be-evil-company/kulala.nvim"],
      "Standalone tools were lost"
    )
    assert(not plugins["vscode-neovim/vscode-multi-cursor.nvim"], "Standalone imported VS Code multi-cursor")
    assert(vim.o.winbar:find("standalone.ui.winbar", 1, true), "Winbar still references the old module")
  end
  for name in pairs(package.loaded) do
    assert(not name:match("^" .. other .. "%.config"), "Loaded configuration from the other profile: " .. name)
    assert(not name:match("^" .. other .. "%.plugins"), "Loaded plugins from the other profile: " .. name)
  end
  for _, path in ipairs(vim.fn.glob(config .. "/**/*.lua", false, true)) do
    assert(loadfile(path))
  end
  for _, path in ipairs(vim.fn.glob(config .. "/lua/shared/**/*.lua", false, true)) do
    local source = table.concat(vim.fn.readfile(path), "\n")
    assert(not source:find("require%([\"']standalone%."), "Shared module imports standalone code: " .. path)
    assert(not source:find("require%([\"']vscode_nvim%."), "Shared module imports VS Code config: " .. path)
  end
  print(profile .. ": no VS Code namespace conflict; routing, shared plugins, LazyVim hooks and Lua syntax OK")
end

local ok, err = pcall(check)
if not ok then
  print(err)
  vim.cmd("cquit 1")
end

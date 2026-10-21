local M = {}

function M.setup(vscode)
  local opts = { noremap = true, silent = true }
  -- Basic vim mappings
  vim.keymap.set("v", "p", '"_dP') -- Paste without overwriting clipboard
  vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>") -- Clear search highlight

  -- Movement improvements
  vim.cmd("nmap j gj") -- Skip folds down
  vim.cmd("nmap k gk") -- skip folds up

  -- Movement mappings
  local movement_mappings = {
    { "<Space>", "<Nop>" }, -- Nop
    { "gh", "^" }, -- Go to line start
    { "gl", "$" }, -- Go to line end
  }
  -- Select, delete, copy all mappings
  vim.keymap.set("n", "vag", "ggVG", opts) -- Select all
  vim.keymap.set("n", "dag", "ggVGd", opts) -- Delete all
  vim.keymap.set("n", "yag", "ggVGy", opts) -- Copy all

  -- Apply movement mappings to normal and visual modes
  for _, mapping in ipairs(movement_mappings) do
    local key, action = mapping[1], mapping[2]
    vim.keymap.set("n", key, action, opts)
    vim.keymap.set("v", key, action, opts)
  end

  -- Visual star search
  vim.keymap.set("v", "*", function()
    local lines = vim.fn.getline("'<", "'>")
    local text = ""

    if type(lines) == "table" then
      if #lines == 1 then
        text = lines[1]:sub(vim.fn.col("'<"), vim.fn.col("'>"))
      else
        text = table.concat(lines, "\n")
      end
    else
      text = lines
    end

    vim.fn.setreg("/", text)
    vscode.action("actions.find")
  end, opts)

end

return M

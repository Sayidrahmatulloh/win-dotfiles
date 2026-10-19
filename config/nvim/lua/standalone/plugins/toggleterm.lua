local function available_height()
  return vim.o.lines - vim.o.cmdheight - (vim.o.laststatus == 0 and 0 or 1)
end

local function terminal_height()
  return math.max(1, math.min(12, math.floor(available_height() * 0.35)))
end

return {
  "akinsho/toggleterm.nvim",
  cmd = { "ToggleTerm", "TermExec" },
  keys = {
    { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
  },
  opts = {
    shell = function()
      return require("standalone.config.shell").terminal()
    end,
    direction = "float",
    float_opts = {
      border = "curved",
      width = function()
        return math.max(1, vim.o.columns - 4)
      end,
      height = terminal_height,
      row = function()
        return math.max(0, available_height() - terminal_height() - 2)
      end,
      col = 1,
      winblend = 0,
    },
    shade_terminals = false,
    start_in_insert = true,
    persist_size = true,
    winbar = { enabled = false },
    on_open = function(term)
      vim.wo[term.window].winbar = ""
      vim.keymap.set({ "t", "n" }, "<Esc>", function()
        term:close()
      end, { buffer = term.bufnr, silent = true, desc = "Hide terminal and return to editor" })
    end,
  },
}

local terminal = require("standalone.features.terminal")
local layout = require("standalone.features.terminal.layout")

return {
  "akinsho/toggleterm.nvim",
  cmd = { "ToggleTerm", "TermExec", "TermSelect" },
  keys = {
    {
      "<leader>tt",
      function() terminal.toggle() end,
      desc = "Toggle terminal panel",
    },
    {
      "<leader>tn",
      function() terminal.new() end,
      desc = "New terminal",
    },
    {
      "<leader>ts",
      function() terminal.select() end,
      desc = "Select terminal",
    },
    {
      "<leader>tf",
      function() terminal.maximize() end,
      mode = { "n", "t" },
      desc = "Maximize / restore terminal",
    },
    {
      "<leader>1",
      function() terminal.switch(1) end,
      mode = { "n", "t" },
      desc = "Terminal #1",
    },
    {
      "<leader>2",
      function() terminal.switch(2) end,
      mode = { "n", "t" },
      desc = "Terminal #2",
    },
    {
      "<leader>3",
      function() terminal.switch(3) end,
      mode = { "n", "t" },
      desc = "Terminal #3",
    },
  },
  opts = {
    shell = function()
      return require("standalone.platform.shell").terminal()
    end,
    direction = "float",
    float_opts = layout.options(),
    shade_terminals = false,
    start_in_insert = true,
    persist_mode = false,
    persist_size = true,
    close_on_exit = true,
    winbar = { enabled = false },
    on_open = function(term)
      terminal.on_open(term)
    end,
  },
}

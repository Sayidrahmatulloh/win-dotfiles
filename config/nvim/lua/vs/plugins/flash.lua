return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {},
  config = function()
    require("flash").setup()
    vim.api.nvim_set_hl(0, "FlashLabel", {
      bg = "#542fa4",
      fg = "#ffffff",
    })
    vim.api.nvim_set_hl(0, "FlashMatch", {
      bg = "#6b9080",
      fg = "#ffffff",
    })
    vim.api.nvim_set_hl(0, "FlashCurrent", {
      bg = "#6b9080",
      fg = "#ffffff",
    })
  end,
  keys = {
    {
      "s",
      mode = { "n", "x", "o" },
      function()
        require("flash").jump()
      end,
      desc = "Flash",
    },
    {
      "S",
      mode = { "n", "x", "o" },
      function()
        require("flash").treesitter()
      end,
      desc = "Flash Treesitter",
    },
    {
      "gs",
      mode = { "n", "x", "o" },
      function()
        require("flash").treesitter()
      end,
      desc = "Flash Treesitter (alternative)",
    },
    {
      "r",
      mode = "o",
      function()
        require("flash").remote()
      end,
      desc = "Remote Flash",
    },
    {
      "R",
      mode = { "o", "x" },
      function()
        require("flash").treesitter_search()
      end,
      desc = "Treesitter Search",
    },
    {
      "<c-s>",
      mode = { "c" },
      function()
        require("flash").toggle()
      end,
      desc = "Toggle Flash Search",
    },
  },
}

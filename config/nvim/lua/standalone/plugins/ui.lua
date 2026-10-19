return {
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "catppuccin-mocha", news = { lazyvim = false, neovim = false } },
  },
  { "akinsho/bufferline.nvim", enabled = false },
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      opts = vim.tbl_deep_extend("force", opts, {
        cmdline = { enabled = true, view = "cmdline_popup" },
        views = {
          cmdline_popup = require("standalone.ui.popup").cmdline(),
        },
        presets = { command_palette = false },
        popupmenu = { enabled = false },
        lsp = {
          signature = { enabled = false },
          hover = { enabled = true },
        },
      })
      require("standalone.ui.popup").configure_noice(opts)
      return opts
    end,
  },
  { "lewis6991/gitsigns.nvim", enabled = false },
  { "folke/todo-comments.nvim", enabled = false },
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      opts.preset = "modern"
      opts.delay = 350
      opts.triggers = { { "<auto>", mode = "nxso" } }
      opts.spec = opts.spec or {}
      vim.list_extend(opts.spec, {
        { "<leader>f", group = "Files" },
        { "<leader>s", group = "Search" },
        { "<leader>c", group = "Code" },
        { "<leader>b", group = "Buffers" },
        { "<leader>w", group = "Windows / text case" },
        { "<leader>t", group = "Terminal" },
        { "<leader>u", group = "UI" },
      })
    end,
  },
}

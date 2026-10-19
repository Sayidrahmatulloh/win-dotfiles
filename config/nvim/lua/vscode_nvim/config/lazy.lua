-- VS Code has its own plugin directory and lockfile.
require("shared.bootstrap").setup({
  spec = {
    { import = "shared.plugins" },
    { import = "vscode_nvim.plugins" },
  },
  root = vim.fn.stdpath("data") .. "/lazy-vscode",
  lockfile = vim.fn.stdpath("config") .. "/lazy-lock-vscode.json",

  defaults = {
    lazy = true,
  },

  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "zipPlugin",
        "netrwPlugin",
        "matchit",
        "matchparen",
      },
    },
  },
})

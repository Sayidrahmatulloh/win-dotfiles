-- Plugin manager for the VS Code Neovim environment.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup("vs.plugins", {
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

return {
  "nvim-treesitter/nvim-treesitter",
  init = function()
    require("standalone.platform.treesitter").setup()
  end,
  opts = { ensure_installed = { "cpp", "css", "go", "rust", "vue" } },
}

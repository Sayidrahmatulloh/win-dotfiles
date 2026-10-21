-- Loading overrides for editing plugins declared in shared/plugins.
return {
  { "numToStr/Comment.nvim", event = "VeryLazy" },
  { "folke/ts-comments.nvim", enabled = false },
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = {
      { "<leader>st", "<cmd>Telescope<cr>", desc = "Telescope pickers" },
    },
  },
}

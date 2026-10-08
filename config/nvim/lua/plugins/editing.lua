-- Share editor-independent behavior with the VS Code configuration.
local comment = vim.deepcopy(require("vs.plugins.comment"))
comment.event = "VeryLazy"

local telescope = vim.deepcopy(require("vs.plugins.telescope"))
telescope.cmd = "Telescope"
telescope.keys = {
  { "<leader>st", "<cmd>Telescope<cr>", desc = "Telescope pickers" },
}

local textcase = vim.deepcopy(require("vs.plugins.text-case"))
textcase.event = "VeryLazy"
textcase.keys = {
  { "<leader>sc", "<cmd>TextCaseOpenTelescope<cr>", desc = "Text case picker" },
}
local cases = {
  wu = "to_upper_case", wl = "to_lower_case", wt = "to_title_case",
  ws = "to_snake_case", wc = "to_camel_case", wp = "to_pascal_case", wk = "to_dash_case",
}
for key, method in pairs(cases) do
  table.insert(textcase.keys, {
    "<leader>" .. key,
    function() require("textcase").current_word(method) end,
    desc = method:gsub("to_", ""):gsub("_", " "),
  })
end

local textobjects = require("vs.plugins.treesitter")[2]

return {
  comment,
  { "folke/ts-comments.nvim", enabled = false },
  vim.deepcopy(require("vs.plugins.exchange")),
  vim.deepcopy(require("vs.plugins.flash")),
  telescope,
  textcase,
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "cpp", "css", "go", "rust", "vue" } },
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = textobjects.config,
  },
}

return {
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "catppuccin-mocha", news = { lazyvim = false, neovim = false } },
  },
  { "akinsho/bufferline.nvim",  enabled = false },
  {
    "folke/noice.nvim",
    opts = {
      cmdline = { enabled = true, view = "cmdline_popup" },
      views = {
        cmdline_popup = { position = { row = "20%", col = "50%" } },
      },
      presets = { command_palette = false },
      popupmenu = { enabled = false },
      lsp = {
        signature = { enabled = false },
        hover = { enabled = true },
      },
    },
  },
  { "lewis6991/gitsigns.nvim",  enabled = false },
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
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = { enabled = false },
      indent = { enabled = false },
      scroll = { enabled = false },
      animate = { enabled = false },
      words = { enabled = false },
      notifier = { enabled = false },
      statuscolumn = { enabled = false },
      explorer = { replace_netrw = false },
      picker = {
        layout = { preset = "vscode" },
        sources = {
          explorer = {
            on_show = function(picker) require("config.ui").explorer_on_show(picker) end,
            hidden = true,
            diagnostics = false,
            git_status = false,
            git_untracked = false,
            layout = {
              preset = "sidebar",
              preview = false,
              layout = {
                box = "vertical",
                backdrop = false,
                border = "none",
                height = 0,
                position = "right",
                width = 34,
                min_width = 26,
                { win = "input", height = 1, border = "bottom", title = "{title}", title_pos = "left" },
                { win = "list", border = "none" },
              },
            },
          },
        },
      },
    },
  },
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "default",
        ["<CR>"] = { "fallback" },
        ["<C-y>"] = { "select_and_accept", "fallback" },
        ["<Tab>"] = { "snippet_forward", "select_and_accept", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
      },
      completion = {
        menu = { enabled = false, auto_show = false },
        documentation = { auto_show = false, window = { border = "rounded" } },
        list = { selection = { preselect = false, auto_insert = false } },
        ghost_text = { enabled = true, show_without_selection = true, show_without_menu = true },
      },
      signature = { enabled = false },
      cmdline = {
        completion = { menu = { auto_show = false }, ghost_text = { enabled = false } },
      },
    },
  },
}

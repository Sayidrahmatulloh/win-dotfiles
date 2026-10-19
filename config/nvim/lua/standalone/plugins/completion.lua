return {
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
}

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = false,
        virtual_lines = false,
        signs = false,
        underline = false,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
      },
      inlay_hints = { enabled = false },
      codelens = { enabled = false },
      servers = { svelte = {} },
    },
  },
}

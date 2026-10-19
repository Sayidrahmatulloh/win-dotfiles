return {
  {
    "stevearc/conform.nvim",
    opts = {
      -- The Prettier extra handles JS/TS, JSON, CSS, HTML, Markdown and YAML.
      -- Svelte uses Prettier when its project plugin is configured, or LSP otherwise.
      formatters_by_ft = { svelte = { "prettier" } },
    },
  },
}

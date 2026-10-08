return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      -- Keep LazyVim's styling; replace the internal terminal URI with a short label.
      local sections = vim.deepcopy(opts.sections)
      sections.lualine_c = {
        function()
          local id = vim.b.toggle_number
          local term = id and require("toggleterm.terminal").get(id)
          if term and term.display_name then
            return term.display_name
          end
          local shell = vim.fs.basename(vim.o.shell:gsub("\\", "/")):gsub("%.exe$", "")
          return shell .. (id and (" #" .. id) or "")
        end,
      }
      opts.extensions = opts.extensions or {}
      table.insert(opts.extensions, { filetypes = { "toggleterm" }, sections = sections })
    end,
  },
}

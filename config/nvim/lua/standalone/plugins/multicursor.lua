local palette = require("shared.colors")

return {
  "jake-stewart/multicursor.nvim",
  branch = "1.0",
  event = "VeryLazy",
  config = function()
    local mc = require("multicursor-nvim")
    mc.setup()
    local function map(key, callback, desc)
      vim.keymap.set({ "n", "x" }, key, callback, { silent = true, desc = desc })
    end
    map("<C-d>", function()
      mc.matchAddCursor(1)
    end, "Add cursor at next match")
    map("<C-S-d>", function()
      mc.matchAddCursor(-1)
    end, "Add cursor at previous match")
    map("<C-S-l>", mc.matchAllAddCursors, "Add cursors at all matches")
    map("<leader>an", function()
      mc.matchAddCursor(1)
    end, "Add cursor at next match")
    map("<leader>ma", mc.matchAllAddCursors, "Add cursors at all matches")
    map("mm", mc.toggleCursor, "Toggle cursor at current position")
    map("mcm", mc.clearCursors, "Clear cursors")
    mc.addKeymapLayer(function(set)
      set("n", "<Esc>", function()
        mc.clearCursors()
        vim.cmd.nohlsearch()
      end)
    end)
    local function highlights()
      vim.api.nvim_set_hl(0, "MultiCursorCursor", { bg = palette.cursor, fg = palette.white })
      vim.api.nvim_set_hl(0, "MultiCursorVisual", { link = "Visual" })
      vim.api.nvim_set_hl(0, "MultiCursorDisabledCursor", { reverse = true })
      vim.api.nvim_set_hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
    end
    highlights()
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("minimal_multicursor_colors", { clear = true }),
      callback = highlights,
    })
  end,
}

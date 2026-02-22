return {
    "vscode-neovim/vscode-multi-cursor.nvim",
    event = "VeryLazy",
    cond = not not vim.g.vscode,

    opts = {},

    config = function(_, opts)
        local cursors = require("vscode-multi-cursor")

        cursors.setup(opts)

        vim.api.nvim_set_hl(0, "VSCodeCursor", {
            bg = "#542fa4",
            fg = "#ffffff",
        })

        vim.api.nvim_set_hl(0, "VSCodeCursorRange", {
            bg = "#542fa4",
            fg = "#ffffff",
            default = true,
        })

        -- Keymaps
        local keymap = vim.keymap.set

        keymap({ "n", "x", "i" }, "<C-d>", function()
            cursors.addSelectionToNextFindMatch()
        end, { desc = "Add selection to next match" })

        keymap({ "n", "x", "i" }, "<C-S-d>", function()
            cursors.addSelectionToPreviousFindMatch()
        end, { desc = "Add selection to previous match" })

        keymap({ "n", "x", "i" }, "<C-S-l>", function()
            cursors.selectHighlights()
        end, { desc = "Select highlights" })

        keymap({ "n", "x" }, "mm", cursors.create_cursor, {
            expr = true,
            desc = "Create cursor",
        })

        keymap("n", "mcm", cursors.cancel, {
            desc = "Cancel cursors",
        })

        keymap("n", "<C-d>", "mciw*:nohl<CR>", {
            remap = true,
            desc = "Multi cursor word",
        })
    end,
}

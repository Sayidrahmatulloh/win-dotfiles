return {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm", "TermExec" },
    keys = {
        { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
    },
    opts = {
        size = 12,
        direction = "horizontal",
        shade_terminals = false,
        start_in_insert = true,
        persist_size = true,
        winbar = { enabled = false },
        on_open = function(term)
            vim.keymap.set({ "t", "n" }, "<Esc>", function()
                term:close()
            end, { buffer = term.bufnr, silent = true, desc = "Hide terminal and return to editor" })
        end,
    },
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        install_dir = vim.fn.stdpath("data") .. "/treesitter",
      })


      require("nvim-treesitter").install({
        "bash", "c", "cpp", "css", "go", "html",
        "javascript", "json", "lua", "markdown",
        "markdown_inline", "python", "regex", "rust",
        "toml", "tsx", "typescript", "vim", "vue",
        "vimdoc", "yaml",
      })


      vim.api.nvim_create_autocmd("FileType", {
        callback = function() pcall(vim.treesitter.start) end,
      })
    end,
    init = function()
      require("nvim-treesitter.install").compilers = { "cl", "gcc", "clang" }
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    lazy = false,
    dependencies = {
      { "nvim-treesitter/nvim-treesitter", branch = "main" },
    },
    init = function()
      -- Disable built-in ftplugin mappings globally to prevent conflicts
      vim.g.no_plugin_maps = true
    end,
    config = function()
      -- ── Global options ──────────────────────────────────────
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true,             -- jump forward if cursor is not inside a textobject
          selection_modes = {
            ["@parameter.outer"] = "v", -- charwise visual
            ["@function.outer"]  = "V", -- linewise visual
            ["@class.outer"]     = "V", -- linewise visual
          },
          include_surrounding_whitespace = false,
        },
        move = {
          set_jumps = true, -- add every jump to the jumplist (C-o / C-i)
        },
      })

      -- ── SELECT keymaps (Visual-mode + Operator-pending) ─────
      -- Uses the official API from the main branch README
      local sel = require("nvim-treesitter-textobjects.select")

      local sel_maps = {
        -- functions
        af = "@function.outer",     -- outer function
        ["if"] = "@function.inner", -- inner function (body only)
        -- classes
        ac = "@class.outer",
        ic = "@class.inner",
        -- conditionals (if / else / switch)
        ai = "@conditional.outer",
        ii = "@conditional.inner",
        -- loops (for / while)
        al = "@loop.outer",
        il = "@loop.inner",
        -- function calls
        am = "@call.outer",
        im = "@call.inner",
        -- blocks  { ... }
        ab = "@block.outer",
        ib = "@block.inner",
        -- parameters / arguments
        aa = "@parameter.outer",
        ia = "@parameter.inner",
        -- comments
        ["a/"] = "@comment.outer",
        ["i/"] = "@comment.inner",
        -- statements
        as = "@statement.outer",
        -- return statements
        ar = "@return.outer",
        ir = "@return.inner",
        -- html / jsx attributes
        ae = "@attribute.outer",
        ie = "@attribute.inner",
      }

      for key, query in pairs(sel_maps) do
        vim.keymap.set({ "x", "o" }, key, function()
          sel.select_textobject(query, "textobjects")
        end, { silent = true, desc = "Select " .. query })
      end

      -- ── MOVE keymaps (Normal + Visual + Operator-pending) ───
      -- ] = forward/next     [ = backward/previous
      -- lowercase = start    uppercase = end
      local mv = require("nvim-treesitter-textobjects.move")

      local mv_maps = {
        -- next start ──────────────────────────────────────────
        ["]f"] = { fn = mv.goto_next_start, q = "@function.outer" },
        ["]c"] = { fn = mv.goto_next_start, q = "@class.outer" },
        ["]i"] = { fn = mv.goto_next_start, q = "@conditional.outer" },
        ["]l"] = { fn = mv.goto_next_start, q = "@loop.outer" },
        ["]m"] = { fn = mv.goto_next_start, q = "@call.outer" },
        ["]b"] = { fn = mv.goto_next_start, q = "@block.outer" },
        ["]a"] = { fn = mv.goto_next_start, q = "@parameter.inner" },
        ["]s"] = { fn = mv.goto_next_start, q = "@statement.outer" },
        ["]r"] = { fn = mv.goto_next_start, q = "@return.outer" },
        -- next end ────────────────────────────────────────────
        ["]F"] = { fn = mv.goto_next_end, q = "@function.outer" },
        ["]C"] = { fn = mv.goto_next_end, q = "@class.outer" },
        ["]I"] = { fn = mv.goto_next_end, q = "@conditional.outer" },
        ["]L"] = { fn = mv.goto_next_end, q = "@loop.outer" },
        ["]M"] = { fn = mv.goto_next_end, q = "@call.outer" },
        ["]B"] = { fn = mv.goto_next_end, q = "@block.outer" },
        ["]A"] = { fn = mv.goto_next_end, q = "@parameter.inner" },
        -- previous start ──────────────────────────────────────
        ["[f"] = { fn = mv.goto_previous_start, q = "@function.outer" },
        ["[c"] = { fn = mv.goto_previous_start, q = "@class.outer" },
        ["[i"] = { fn = mv.goto_previous_start, q = "@conditional.outer" },
        ["[l"] = { fn = mv.goto_previous_start, q = "@loop.outer" },
        ["[m"] = { fn = mv.goto_previous_start, q = "@call.outer" },
        ["[b"] = { fn = mv.goto_previous_start, q = "@block.outer" },
        ["[a"] = { fn = mv.goto_previous_start, q = "@parameter.inner" },
        ["[s"] = { fn = mv.goto_previous_start, q = "@statement.outer" },
        ["[r"] = { fn = mv.goto_previous_start, q = "@return.outer" },
        -- previous end ────────────────────────────────────────
        ["[F"] = { fn = mv.goto_previous_end, q = "@function.outer" },
        ["[C"] = { fn = mv.goto_previous_end, q = "@class.outer" },
        ["[I"] = { fn = mv.goto_previous_end, q = "@conditional.outer" },
        ["[L"] = { fn = mv.goto_previous_end, q = "@loop.outer" },
        ["[M"] = { fn = mv.goto_previous_end, q = "@call.outer" },
        ["[B"] = { fn = mv.goto_previous_end, q = "@block.outer" },
        ["[A"] = { fn = mv.goto_previous_end, q = "@parameter.inner" },
      }

      for key, map in pairs(mv_maps) do
        vim.keymap.set({ "n", "x", "o" }, key, function()
          map.fn(map.q, "textobjects")
        end, { silent = true, desc = key .. " " .. map.q })
      end

      -- ── SWAP keymaps (Normal mode only) ─────────────────────
      local sw = require("nvim-treesitter-textobjects.swap")

      vim.keymap.set("n", "<leader>na", function()
        sw.swap_next("@parameter.inner", "textobjects")
      end, { desc = "Swap with next parameter" })

      vim.keymap.set("n", "<leader>nf", function()
        sw.swap_next("@function.outer", "textobjects")
      end, { desc = "Swap with next function" })

      vim.keymap.set("n", "<leader>pa", function()
        sw.swap_previous("@parameter.inner", "textobjects")
      end, { desc = "Swap with previous parameter" })

      vim.keymap.set("n", "<leader>pf", function()
        sw.swap_previous("@function.outer", "textobjects")
      end, { desc = "Swap with previous function" })

      vim.keymap.set("n", "<leader>nc", function()
        sw.swap_next("@class.outer", "textobjects")
      end, { desc = "Swap with next class/interface" })

      vim.keymap.set("n", "<leader>pc", function()
        sw.swap_previous("@class.outer", "textobjects")
      end, { desc = "Swap with previous class/interface" })

      local rep = require("nvim-treesitter-textobjects.repeatable_move")
      vim.keymap.set({ "n", "x", "o" }, ";", rep.repeat_last_move_next)
      vim.keymap.set({ "n", "x", "o" }, "'", rep.repeat_last_move_previous)


      vim.keymap.set({ "n", "x", "o" }, "f", rep.builtin_f_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "F", rep.builtin_F_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "t", rep.builtin_t_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "T", rep.builtin_T_expr, { expr = true })
    end,
  },
}

return {
  {
    "dont-be-evil-company/kulala.nvim",
    -- Keep the curl-based release; v6 requires a separate licensed backend.
    version = "5.3.4",
    submodules = false,
    ft = { "http", "rest" },
    keys = {
      {
        "<leader>rq",
        function()
          require("kulala").run()
        end,
        ft = { "http", "rest" },
        desc = "Send HTTP request",
      },
      {
        "<leader>rr",
        function()
          require("kulala").replay()
        end,
        ft = { "http", "rest" },
        desc = "Repeat last HTTP request",
      },
      {
        "<leader>ro",
        function()
          require("kulala").open()
        end,
        ft = { "http", "rest" },
        desc = "Open HTTP response",
      },
      {
        "<leader>rE",
        function()
          require("kulala").set_selected_env()
        end,
        ft = { "http", "rest" },
        desc = "Select HTTP environment",
      },
    },
    init = function()
      vim.filetype.add({ extension = { http = "http", rest = "http" } })
    end,
    opts = function()
      local available = vim.o.lines - vim.o.cmdheight - (vim.o.laststatus == 0 and 0 or 1)
      local height = math.max(1, math.floor(available * 0.45))
      return {
        global_keymaps = false,
        vscode_rest_client_environmentvars = true,
        lsp = { enable = false },
        ui = {
          display_mode = "float",
          win_opts = {
            border = "rounded",
            width = math.max(1, vim.o.columns - 4),
            height = height,
            row = math.max(0, available - height - 2),
            col = 1,
          },
          default_view = "headers_body",
        },
      }
    end,
  },
}

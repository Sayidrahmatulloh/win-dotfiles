local ignore = require("standalone.features.files.ignore")
local popup = require("standalone.ui.popup")
local picker_ui = require("standalone.features.files.picker")
local explorer_ui = require("standalone.features.files.explorer")

local function quick_open(overrides)
  return vim.tbl_deep_extend("force", {
    formatters = { file = { filename_only = true } },
    layout = { preset = "quick_open" },
    prompt = " ",
    on_show = picker_ui.on_show,
    format = picker_ui.format_file,
  }, overrides or {})
end

return {
  "folke/snacks.nvim",
  keys = require("standalone.keymaps.defaults").plugin_keys("snacks"),
  opts = {
    dashboard = { enabled = false },
    indent = { enabled = false },
    scroll = { enabled = false },
    animate = { enabled = false },
    words = { enabled = false },
    notifier = { enabled = false },
    statuscolumn = { enabled = false },
    explorer = { replace_netrw = false },
    input = { win = popup.input() },
    picker = {
      win = { input = { wo = { winbar = "" } } },
      config = ignore.configure,
      ignored = false,
      exclude = { "**/node_modules", "**/node_modules/**", "**/.git", "**/.git/**" },
      filter = { filter = ignore.filter },
      transform = function(item, ctx)
        return ignore.filter(item, ctx.filter)
      end,
      layout = { preset = "vscode" },
      layouts = {
        vscode = { config = popup.search_layout },
        quick_open = {
          config = popup.search_layout,
          preview = false,
          layout = {
            box = "vertical",
            backdrop = false,
            border = "none",
            width = popup.width,
            min_width = popup.min_width,
            max_width = popup.max_width,
            height = 0.40,
            row = 0.25,
            { win = "input", height = 1, border = popup.border },
            { win = "list", border = "hpad" },
          },
        },
      },
      sources = {
        files = quick_open({ cmd = "fd", args = { "--no-require-git" } }),
        smart = quick_open({
          transform = function(item, ctx)
            if not ignore.filter(item, ctx.filter) then
              return false
            end
            return Snacks.picker.transform.unique_file(item, ctx)
          end,
        }),
        recent = quick_open(),
        buffers = quick_open(),
        grep = { args = { "--no-require-git" } },
        explorer = {
          win = {
            input = { keys = { ["<Esc>"] = false } },
            list = {
              wo = { winbar = "" },
              keys = {
                ["<Esc>"] = false,
                ["\\"] = "explorer_close_all",
                ["w"] = {
                  explorer_ui.editor,
                  desc = "Return to editor",
                },
              },
            },
          },
          config = function(opts)
            ignore.configure(opts)
            return require("snacks.picker.source.explorer").setup(opts)
          end,
          on_show = explorer_ui.on_show,
          hidden = true,
          ignored = false,
          diagnostics = false,
          -- Ignore discovery needs Git status even though badges stay hidden.
          git_status = true,
          git_untracked = true,
          format = function(item, picker)
            return Snacks.picker.format.file(vim.tbl_extend("force", item, { status = false }), picker)
          end,
          icons = {
            files = { dir = " ", dir_open = " " },
            tree = { vertical = "  ", middle = "  ", last = "  " },
          },
          layout = {
            preset = "sidebar",
            preview = false,
            hidden = { "input" },
            layout = {
              box = "vertical",
              backdrop = false,
              border = "rounded",
              position = "float",
              relative = "editor",
              zindex = 30,
              row = 0,
              col = -1,
              width = function()
                return math.max(1, math.min(math.max(26, math.floor(vim.o.columns * 0.31)), vim.o.columns - 4))
              end,
              height = function()
                return math.max(1, vim.o.lines - vim.o.cmdheight - (vim.o.laststatus == 0 and 0 or 1) - 2)
              end,
              { win = "input", height = 1, border = "none" },
              { win = "list", border = "none" },
            },
          },
        },
      },
    },
  },
}

-- Code first: quiet UI, deliberate suggestions, familiar VS Code spacing.
require("shared.options")
vim.g.autoformat = true
vim.g.snacks_animate = false

local opt = vim.opt
opt.guifont = "Operator Mono Lig:h14"
opt.number = true
opt.relativenumber = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.scrolloff = 5
opt.sidescrolloff = 5
opt.wrap = false
opt.textwidth = 0
opt.colorcolumn = ""
opt.cursorline = false
opt.cursorcolumn = false
opt.list = false
opt.signcolumn = "no"
opt.laststatus = 3
opt.showtabline = 0
opt.winbar = require("standalone.ui.winbar").expression
opt.showmode = false
opt.showcmd = false
opt.ruler = false
opt.cmdheight = 0
opt.foldcolumn = "0"
opt.fillchars = { eob = " ", fold = " ", foldopen = " ", foldclose = " ", foldsep = " " }
opt.termguicolors = true
opt.mouse = "a"
opt.splitright = true
opt.splitbelow = true
opt.confirm = true
opt.undofile = true
opt.swapfile = false
opt.updatetime = 250
opt.timeoutlen = 400
opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkon0"

require("standalone.platform.shell").setup()

-- Code first: quiet UI, deliberate suggestions, familiar VS Code spacing.
vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.g.autoformat = true
vim.g.snacks_animate = false

local opt = vim.opt
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
opt.winbar = require("config.ui").winbar_expr
opt.showmode = false
opt.showcmd = false
opt.ruler = false
opt.cmdheight = 0
opt.foldcolumn = "0"
opt.fillchars = { eob = " ", fold = " ", foldopen = " ", foldclose = " ", foldsep = " " }
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.clipboard = "unnamedplus"
opt.fileformats = { "unix", "dos" }
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

-- Use PowerShell without loading the interactive profile.
if vim.fn.has("win32") == 1 and vim.fn.executable("pwsh") == 1 then
  opt.shell = "pwsh"
  opt.shellcmdflag = "-NoLogo -NoProfile -NonInteractive -Command"
  opt.shellquote = ""
  opt.shellxquote = ""
  opt.shellredir = "2>&1 | Out-File -Encoding UTF8 %s"
  opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s"
end

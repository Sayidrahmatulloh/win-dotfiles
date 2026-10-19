-- Called by repair-nvim.ps1 after checking that no parser build is active.
local function repair()
  local data = vim.fn.stdpath("data")
  vim.opt.rtp:prepend(data .. "/lazy/nvim-treesitter")
  if not vim.env.CC and vim.fn.executable("gcc") == 1 then
    vim.env.CC = "gcc"
  end
  local treesitter = require("nvim-treesitter")
  treesitter.setup({ install_dir = data .. "/site" })
  treesitter.install({ "diff" }, { max_jobs = 1 }):wait(120000)
  local parser = data .. "/site/parser/diff.so"
  assert(vim.uv.fs_stat(parser), "The diff parser was not installed")
  vim.treesitter.language.add("diff", { path = parser })
  local parsed = vim.treesitter.get_string_parser("+added\n-removed\n", "diff"):parse()
  assert(parsed and parsed[1], "The diff parser failed to parse text")
  print("Treesitter diff parser installed and verified")
end

local ok, err = pcall(repair)
if not ok then
  print(err)
  vim.cmd("cquit 1")
end

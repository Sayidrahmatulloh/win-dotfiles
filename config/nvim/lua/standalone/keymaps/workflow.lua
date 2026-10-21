local explorer = require("standalone.features.files.explorer")

return {
  fo = function()
    Snacks.picker.files()
  end,
  fs = "<cmd>write<cr>",
  fn = "<cmd>enew<cr>",
  fl = function()
    Snacks.picker.recent()
  end,
  fe = explorer.focus,
  sd = function()
    explorer.resize(4)
  end,
  si = function()
    explorer.resize(-4)
  end,
  sp = function()
    Snacks.picker.grep()
  end,
  sy = function()
    Snacks.picker.lsp_symbols()
  end,
  sx = function()
    Snacks.picker.diagnostics()
  end,
  cn = vim.lsp.buf.rename,
  ca = vim.lsp.buf.code_action,
  cF = function()
    LazyVim.format({ force = true })
  end,
  bs = function()
    Snacks.picker.buffers()
  end,
  bd = function()
    Snacks.bufdelete()
  end,
  bn = "<cmd>bnext<cr>",
  bp = "<cmd>bprevious<cr>",
  wv = "<cmd>vsplit<cr>",
  wh = "<cmd>split<cr>",
  wd = "<cmd>close<cr>",
  ["w="] = "<C-w>=",
  wj = "<C-w>j",
  wK = "<C-w>k",
}

return {
  "tommcdo/vim-exchange",
  event = "VeryLazy",
  keys = {
    { "cx",  mode = { "n", "x" }, desc = "Exchange" },
    { "cxx", mode = "n",          desc = "Exchange line" },
    { "cxc", mode = "n",          desc = "Exchange line / Clear" },
    { "X",   mode = "x",          desc = "Exchange visual" },
  },
}

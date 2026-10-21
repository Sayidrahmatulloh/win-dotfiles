-- Only disable defaults replaced by personal mappings. Keep unrelated LazyVim tools.
local M = {}

M.core = {
  { "n", "<leader>cd" }, -- Line diagnostics: <leader>vd.
  { { "n", "x" }, "<leader>cf" }, -- Format: <leader>fm; normal cf closes a buffer.
  { "n", "<leader>ft" }, -- Terminal: <leader>tt / Ctrl+/ (ToggleTerm).
  { "n", "<leader>fT" },
  { "n", "<leader>-" }, -- Horizontal split: <leader>wh.
  { "n", "<leader>|" }, -- Vertical split: <leader>wv.
  { "n", "<leader>`" }, -- Alternate buffer remains available on <leader>bb.
  { "n", "[b" }, -- Personal buffer navigation: gp / gn, Shift+h / Shift+l.
  { "n", "]b" },
}

local plugins = {
  snacks = {
    "<leader>e", "<leader>E", "<leader>fe", "<leader>fE", -- Sidebar: personal <leader>fe focuses it.
    "<leader>ff", "<leader>fF", -- Files: <leader><space> / <leader>fo.
    "<leader>fr", "<leader>fR", -- Recent: <leader>rl / <leader>fl.
    "<leader>,", -- Buffers: <leader>fb / <leader>bs.
    "<leader>/", "<leader>sg", "<leader>sG", -- Grep: <leader>fg / <leader>sp.
    "<leader>sC", -- Commands: <leader>sa.
    "<leader>sd", -- Diagnostics: <leader>pr / <leader>sx; sd resizes the sidebar.
    "<leader>si", -- Reserved for sidebar resizing.
    "<leader>sp", -- Reserved for project grep, not plugin-spec search.
    "<leader>sa", -- Reserved for commands, not autocmd search.
    "<leader>sc", -- Reserved for the text-case picker.
    "<leader>fg", -- Reserved for grep, not Git file search.
    "<leader>fb", -- Personal buffer picker owns this mapping.
    "<leader><space>", -- Personal file picker owns this mapping.
  },
  lsp = {
    "<leader>cr", -- Rename: <leader>re / <leader>cn.
    "<leader>ss", -- Document symbols: <leader>sy.
  },
}

-- Disable lazy.nvim keys at the plugin spec, so lazy loading cannot restore them.
function M.plugin_keys(name)
  local keys = {}
  for _, lhs in ipairs(assert(plugins[name], "Unknown keymap policy: " .. name)) do
    keys[#keys + 1] = { lhs, false }
  end
  return keys
end

function M.setup()
  for _, mapping in ipairs(M.core) do
    local modes = type(mapping[1]) == "table" and mapping[1] or { mapping[1] }
    for _, mode in ipairs(modes) do
      pcall(vim.keymap.del, mode, mapping[2])
    end
  end
end

return M

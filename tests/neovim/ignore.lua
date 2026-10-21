-- Run from the repository: nvim --headless -u NONE -i NONE -n -l tests/neovim/ignore.lua
local root = vim.fn.getcwd():gsub("\\", "/")
vim.opt.rtp:prepend(root .. "/config/nvim")
local lazy = vim.fn.stdpath("data") .. "/lazy"
if vim.fn.isdirectory(lazy .. "/snacks.nvim") == 0 and vim.env.USERPROFILE then
  lazy = vim.env.USERPROFILE:gsub("\\", "/") .. "/AppData/Local/nvim-data/lazy"
end
vim.opt.rtp:prepend(lazy .. "/snacks.nvim")
vim.opt.columns = 140
vim.opt.lines = 45
local fixture = vim.fn.tempname():gsub("\\", "/")
local function write(path, lines)
  vim.fn.mkdir(vim.fs.dirname(fixture .. "/" .. path), "p")
  vim.fn.writefile(lines, fixture .. "/" .. path)
end
write(".gitignore", { "node_modules/", "dist/", "*.secret", "!keep.secret" })
write("node_modules/pkg/index.js", { "ignore_probe" })
write("dist/output.js", { "ignore_probe" })
write("hidden.secret", { "ignore_probe" })
write("keep.secret", { "ignore_probe" })
write("src/main.ts", { "ignore_probe" })
write("src/.gitignore", { "nested/" })
write("src/nested/hidden.ts", { "ignore_probe" })
write(".visible", { "ignore_probe" })
local picker = dofile(root .. "/config/nvim/lua/standalone/plugins/picker.lua")
require("snacks").setup(picker.opts)
local function results(source, options)
  local picker = Snacks.picker[source](vim.tbl_extend("force", { cwd = fixture }, options or {}))
  assert(
    vim.wait(8000, function()
      return picker.list.win:valid() and not picker:is_active()
    end),
    source .. " timed out"
  )
  vim.wait(200, function()
    return false
  end)
  local found = {}
  for _, item in ipairs(picker:items()) do
    local path = Snacks.picker.util.path(item) or ""
    assert(not path:find("/node_modules/", 1, true), source .. " exposed dependencies")
    assert(not path:find("/dist", 1, true), source .. " exposed build output")
    assert(not path:find("/nested", 1, true), source .. " ignored nested rules")
    assert(not path:find("hidden.secret", 1, true), source .. " ignored wildcard rule")
    found[vim.fs.basename(path)] = true
  end
  picker:close()
  return found
end
local files = results("files")
assert(files["main.ts"] and files["keep.secret"], "Files must preserve normal and negated entries")
local explorer = results("explorer")
assert(explorer["src"] and explorer[".visible"], "Explorer hid valid folders/dotfiles")
local toggled = results("explorer", { ignored = true })
assert(toggled["src"] and not toggled["node_modules"], "Ignored toggle bypasses mandatory exclusions")
local recent = results("recent", {
  finder = function()
    return {
      { file = fixture .. "/node_modules/pkg/index.js", text = "index.js" },
      { file = fixture .. "/src/main.ts", text = "main.ts" },
    }
  end,
})
assert(recent["main.ts"] and not recent["index.js"], "History bypasses ignores")
local grep = results("grep", { search = "ignore_probe", live = false })
assert(grep["main.ts"] and grep["keep.secret"], "Text search lost valid results")
-- fixture was created by this test under the OS temporary directory.
assert(fixture:find(vim.fn.fnamemodify(vim.fn.tempname(), ":h"):gsub("\\", "/"), 1, true) == 1)
vim.fn.delete(fixture, "rf")
print(
  "Ignore regression passed without Git metadata: explorer, file search, history, text search, nested rules and negation"
)
vim.cmd("qa!")

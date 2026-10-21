-- Windows parser failures should disable that parser, not abort FileType events.
local root = assert(vim.fs.root(debug.getinfo(1, "S").source:sub(2), "setup.json"), "Repository root not found")
vim.opt.rtp:prepend(root .. "/config/nvim")

local function check()
  if vim.fn.has("win32") ~= 1 then
    print("Windows parser fallback: skipped on this platform")
    return
  end
  local loads = {}
  LazyVim = {
    treesitter = {
      have = function(ft, query)
        if ft == "missing" then
          return false
        end
        assert(not query or loads[ft], "Queries were loaded before checking the native parser")
        return true
      end,
    },
  }
  vim.treesitter.language.get_lang = function(ft) return ft end
  vim.treesitter.language.add = function(lang)
    loads[lang] = (loads[lang] or 0) + 1
    if lang == "css" or lang == "json" then
      error("An Application Control policy has blocked this file")
    end
    return true
  end
  local guard = require("standalone.platform.treesitter")
  guard.setup()
  local have = LazyVim.treesitter.have
  guard.setup()
  assert(LazyVim.treesitter.have == have, "Repeated setup wrapped the parser API again")
  assert(not have("css", "highlights") and not have("json", "textobjects"))
  assert(not have("json", "folds") and loads.json == 1, "Failed parsers were not cached")
  assert(have("lua", "highlights") and have("lua", "textobjects") and loads.lua == 1)
  assert(not have("missing") and not loads.missing, "An uninstalled parser was loaded")
  print("Windows parsers: blocked libraries fall back; valid parsers and repeated setup work")
end

local ok, err = pcall(check)
if not ok then
  print(err)
  vim.cmd("cquit 1")
end

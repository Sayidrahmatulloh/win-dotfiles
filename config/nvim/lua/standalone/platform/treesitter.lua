local M = {}
local configured = false

-- Query loading must not crash file opening when Windows rejects a native parser.
function M.setup()
  if configured or vim.fn.has("win32") ~= 1 then
    return
  end
  local treesitter = LazyVim.treesitter
  local have = treesitter.have
  local loadable = {}
  treesitter.have = function(what, query)
    if not have(what) then
      return false
    end
    local ft = type(what) == "string" and what or vim.bo[what or 0].filetype
    local lang = vim.treesitter.language.get_lang(ft)
    if not lang then
      return false
    end
    if loadable[lang] == nil then
      local ok, loaded = pcall(vim.treesitter.language.add, lang)
      loadable[lang] = ok and loaded ~= false
    end
    if not loadable[lang] then
      return false
    end
    return have(what, query)
  end
  configured = true
end

return M

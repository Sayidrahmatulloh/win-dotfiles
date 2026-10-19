local M = {}
local prepared = {}
local CACHE_TTL_NS = 2e9
local SCAN_TIMEOUT_MS = 5000

local function normalize_path(path)
  path = vim.fs.normalize(path):gsub("/$", "")
  return vim.fn.has("win32") == 1 and path:lower() or path
end

-- One ignore-aware filesystem scan per picker, shared by all its results.
-- fd applies nested .gitignore rules even to folders without Git metadata.
function M.configure(opts)
  local scan_cwd = opts.cwd or vim.fn.getcwd()
  local cwd = normalize_path(scan_cwd)
  local cache = prepared[cwd]
  if not cache or vim.uv.hrtime() - cache.created > CACHE_TTL_NS then
    cache = { created = vim.uv.hrtime() }
    prepared[cwd] = cache
    if vim.fn.executable("fd") == 1 then
      local result = vim
        .system({
          "fd",
          "--hidden",
          "--no-require-git",
          "--absolute-path",
          "--color",
          "never",
          "--exclude",
          ".git",
          "--exclude",
          "node_modules",
          ".",
          scan_cwd,
        }, { text = true })
        :wait(SCAN_TIMEOUT_MS)
      if result.code == 0 then
        cache.visible = {}
        for entry in result.stdout:gmatch("[^\r\n]+") do
          cache.visible[normalize_path(entry)] = true
        end
      else
        vim.schedule(function()
          vim.notify("Ignore filter: fd could not scan " .. scan_cwd, vim.log.levels.WARN)
        end)
      end
    end
  end
  return opts
end

function M.filter(item, filter)
  local path = Snacks.picker.util.path(item)
  if not path then
    return true
  end
  path = normalize_path(path)
  if ("/" .. path .. "/"):find("/node_modules/", 1, true) or ("/" .. path .. "/"):find("/.git/", 1, true) then
    return false
  end
  local cwd = normalize_path(filter.cwd)
  if path == cwd then
    return true
  end
  if path:sub(1, #cwd + 1) ~= cwd .. "/" then
    return false
  end
  local cache = prepared[cwd]
  if not cache then
    return true
  end
  return not cache.visible or cache.visible[path] == true
end

return M

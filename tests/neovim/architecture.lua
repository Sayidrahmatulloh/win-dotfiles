-- Plugin-free checks for module paths, dependency direction and import cycles.
local root = assert(vim.fs.root(debug.getinfo(1, "S").source:sub(2), "setup.json"), "Repository root not found")
local lua_root = root .. "/config/nvim/lua"

local function check()
  local sources, paths, edges = {}, {}, {}
  for _, path in ipairs(vim.fn.glob(lua_root .. "/**/*.lua", false, true)) do
    local relative = assert(vim.fs.relpath(lua_root, path)):gsub("\\", "/")
    local name = relative:gsub("%.lua$", ""):gsub("/init$", ""):gsub("/", ".")
    assert(not sources[name], "Duplicate Lua module: " .. name)
    sources[name] = table.concat(vim.fn.readfile(path), "\n")
    paths[name] = relative
    assert(loadfile(path))
  end

  local function forbidden(from, target)
    if from:match("^shared%.") then
      return target:match("^standalone[%.]?") or target:match("^vscode_nvim[%.]?")
    elseif from:match("^standalone") then
      if target:match("^vscode_nvim") then
        return true
      end
      if from:match("^standalone%.features%.") then
        return target:match("^standalone%.config%.") or target:match("^standalone%.plugins%.")
      elseif from:match("^standalone%.ui%.") or from:match("^standalone%.platform%.") then
        return target:match("^standalone%.features%.")
          or target:match("^standalone%.plugins%.")
          or target:match("^standalone%.config%.")
      end
    elseif from:match("^vscode_nvim") then
      return target:match("^standalone")
    end
    return false
  end

  for name, source in pairs(sources) do
    edges[name] = {}
    for target in source:gmatch("require%s*%(%s*[\"']([^\"']+)[\"']%s*%)") do
      local local_module = target:match("^shared[%.]?")
        or target:match("^standalone[%.]?")
        or target:match("^vscode_nvim[%.]?")
        or target:match("^config%.")
      if local_module then
        assert(sources[target], paths[name] .. " imports missing module " .. target)
        assert(not forbidden(name, target), "Invalid dependency: " .. name .. " -> " .. target)
        -- Winbar expressions reference their own loaded module at render time.
        if target ~= name then
          table.insert(edges[name], target)
        end
      end
    end
  end

  local visiting, visited = {}, {}
  local function visit(name)
    assert(not visiting[name], "Circular dependency at " .. name)
    if visited[name] then
      return
    end
    visiting[name] = true
    for _, target in ipairs(edges[name]) do
      visit(target)
    end
    visiting[name], visited[name] = nil, true
  end
  for name in pairs(sources) do
    visit(name)
  end
  assert(sources.standalone and sources.vscode_nvim, "Missing environment entry")
  print("Architecture: local imports resolve; environments and layers stay separate; no dependency cycles")
end

local ok, err = pcall(check)
if not ok then
  print(err)
  vim.cmd("cquit 1")
end

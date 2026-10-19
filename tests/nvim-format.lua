-- Formats only temporary files, never project source files.
-- nvim --headless -i NONE -n -u config/nvim/init.lua '+luafile tests/nvim-format.lua' +qa
local fixture
local function check()
  require("lazy").load({ plugins = { "conform.nvim" } })
  vim.cmd.doautocmd("User VeryLazy")
  local conform = require("conform")
  local prettier = require("mason-registry").get_package("prettier")
  fixture = vim.fn.tempname():gsub("\\", "/")
  vim.fn.mkdir(fixture, "p")
  vim.fn.writefile({ '{"semi":false,"singleQuote":true,"tabWidth":4}' }, fixture .. "/.prettierrc.json")
  local file = fixture .. "/main.ts"
  vim.fn.writefile({ 'function greet(){const name="demo";return{name};}' }, file)
  vim.cmd.edit(vim.fn.fnameescape(file))
  local buf = vim.api.nvim_get_current_buf()
  assert(vim.bo[buf].filetype == "typescript", "TypeScript filetype was not detected")
  -- Mason may still be completing the declared Prettier installation.
  assert(
    vim.wait(120000, function()
      return not prettier:is_installing()
        and prettier:is_installed()
        and conform.get_formatter_info("prettier", buf).available
    end, 100),
    "Prettier was not installed or could not be found"
  )
  local sources = LazyVim.format.resolve(buf)
  assert(
    vim.iter(sources):any(function(source)
      return source.active and vim.tbl_contains(source.resolved, "prettier")
    end),
    "LazyVim has no active TypeScript Prettier formatter"
  )
  LazyVim.format({ force = true })
  local formatted = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
  assert(formatted:find("    const name = 'demo'", 1, true), formatted)
  assert(not formatted:find(";", 1, true), "Project semicolon preference was ignored: " .. formatted)

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "function sum(a:number,b:number){return a+b;}" })
  vim.cmd.write()
  local saved = table.concat(vim.fn.readfile(file), "\n")
  assert(saved:find("    return a + b", 1, true), "Format on save did not run: " .. saved)
  assert(not saved:find(";", 1, true), "Format on save ignored project configuration")
  assert(vim.tbl_contains(conform.formatters_by_ft.lua, "stylua"), "Lua formatter was lost")
  print("TypeScript manual formatting and format on save respect project .prettierrc; Lua formatter preserved")
end

local ok, err = pcall(check)
if fixture then
  local temp_root = vim.fn.fnamemodify(vim.fn.tempname(), ":h"):gsub("\\", "/")
  assert(fixture:find(temp_root .. "/", 1, true) == 1, "Unexpected fixture cleanup path")
  vim.fn.delete(fixture, "rf")
end
if not ok then
  print(err)
  vim.cmd("cquit 1")
end

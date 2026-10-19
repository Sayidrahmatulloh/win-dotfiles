-- Run from the repository: nvim --headless -u NONE -i NONE -n -l tests/nvim-shell.lua
local root = vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)))
vim.opt.rtp:prepend(root .. "/config/nvim")

local function check()
  assert(vim.fn.has("win32") == 1, "This regression check requires Windows")
  -- Reproduce a Neovim process whose PATH cannot discover the Store alias.
  local path = vim.env.PATH
  vim.env.PATH = vim.env.SystemRoot .. "/System32"
  local shell = require("standalone.config.shell")
  local executable = assert(shell.powershell(), "PowerShell 7 was not discovered without PATH")
  vim.env.PATH = path
  shell.setup()

  local output = vim.fn.system("Write-Output NVIM_SHELL_COMMAND_OK")
  assert(vim.v.shell_error == 0 and output:find("NVIM_SHELL_COMMAND_OK", 1, true), output)

  local script = [[
$ErrorActionPreference = 'Stop'
Import-Module PSReadLine -ErrorAction Stop
$required = @(Get-Content -LiteralPath $env:NVIM_TEST_MODULE_LIST -Raw | ConvertFrom-Json)
foreach ($name in $required) { Import-Module -Name $name -ErrorAction Stop }
$result = [pscustomobject]@{
  Major = $PSVersionTable.PSVersion.Major
  Version = $PSVersionTable.PSVersion.ToString()
  ReadLine = (Get-Module PSReadLine).Version.ToString()
  Alias = (Get-Alias ll -ErrorAction Stop).Definition
  Prompt = (Get-Command prompt).Definition -match 'posh|render'
  Modules = @($required | ForEach-Object { (Get-Module -Name $_ -ErrorAction Stop).Name })
}
Write-Output ('NVIM_SHELL_PROFILE_OK=' + ($result | ConvertTo-Json -Compress))
]]
  local result = vim
    .system({ executable, "-NoLogo", "-Command", script }, {
      text = true,
      env = { NVIM_TEST_MODULE_LIST = root .. "/config/powershell/modules.json" },
    })
    :wait(30000)
  assert(result.code == 0, result.stdout .. result.stderr)
  local encoded = assert(result.stdout:match("NVIM_SHELL_PROFILE_OK=([^\r\n]+)"), result.stdout)
  local profile = vim.json.decode(encoded)
  assert(profile.Major >= 7 and profile.Alias == "ls" and profile.Prompt, encoded)
  assert(not result.stdout:find("Module '", 1, true), result.stdout)

  -- Exercise the actual ToggleTerm command through Neovim's configured shell.
  local spec = dofile(root .. "/config/nvim/lua/standalone/plugins/toggleterm.lua")
  output = vim.fn.system(spec.opts.shell() .. ' -Command "Write-Output NVIM_TOGGLETERM_OK; exit"')
  assert(vim.v.shell_error == 0 and output:find("NVIM_TOGGLETERM_OK", 1, true), output)
  assert(not output:find("Cannot load PSReadline", 1, true), output)
  assert(not output:find("Module '", 1, true), output)
  print("PowerShell " .. profile.Version .. ": PSReadLine, ll, prompt and all profile modules OK")
end

local ok, err = pcall(check)
if not ok then
  print(err)
  vim.cmd("cquit 1")
end

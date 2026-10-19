local M = {}
local powershell

function M.powershell()
  if powershell then
    return powershell
  end
  -- Store execution aliases can run even when executable("pwsh") returns 0.
  for _, path in ipairs({
    (vim.env.ProgramFiles or "C:/Program Files") .. "/PowerShell/7/pwsh.exe",
    "$USERPROFILE/scoop/apps/pwsh/current/pwsh.exe",
    "$LOCALAPPDATA/Microsoft/WindowsApps/pwsh.exe",
    "$USERPROFILE/AppData/Local/Microsoft/WindowsApps/pwsh.exe",
    vim.fn.exepath("pwsh"),
  }) do
    path = vim.fs.normalize(path)
    if path ~= "" and vim.uv.fs_lstat(path) then
      powershell = path
      return path
    end
  end
end

function M.setup()
  if vim.fn.has("win32") ~= 1 then
    return
  end
  -- Let child PowerShell processes rebuild compatible module paths.
  for key in pairs(vim.fn.environ()) do
    if key:lower() == "psmodulepath" then
      vim.env[key] = nil
    end
  end
  vim.o.shell = '"' .. (M.powershell() or "powershell") .. '"'
  vim.o.shellcmdflag = "-NoLogo -NoProfile -NonInteractive -Command"
  vim.o.shellquote, vim.o.shellxquote = "", ""
  vim.o.shellredir = "2>&1 | Out-File -Encoding UTF8 %s"
  vim.o.shellpipe = vim.o.shellredir
end

function M.terminal()
  if vim.fn.has("win32") ~= 1 then
    return vim.o.shell
  end
  local path = assert(M.powershell(), "PowerShell 7 was not found. Run bootstrap.ps1 to install it.")
  return "& '" .. path:gsub("'", "''") .. "' -NoLogo -NoExit"
end

return M

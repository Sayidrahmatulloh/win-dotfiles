-- Route once; each environment owns its startup and plugin configuration.
if vim.g.vscode then
  require("vscode_nvim")
else
  require("standalone")
end

-- Select the configuration for the current editor environment.
if vim.g.vscode then
  require("vscode_nvim.config")
else
  require("standalone.config")
end

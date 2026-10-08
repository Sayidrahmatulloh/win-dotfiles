-- Select the configuration for the current editor environment.
if vim.g.vscode then
  require("vs.config")
else
  require("config.lazy")
end

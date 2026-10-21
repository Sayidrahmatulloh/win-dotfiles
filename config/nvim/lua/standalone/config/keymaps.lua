-- Loaded by LazyVim after its defaults, so local mappings take precedence.
require("standalone.keymaps.defaults").setup()
require("standalone.keymaps.editor").setup()
require("standalone.keymaps.terminal").setup()
require("standalone.keymaps.workspace").setup()

local actions = require("standalone.keymaps.workflow")
require("shared.workflow").setup(function(key)
  return actions[key]
end)

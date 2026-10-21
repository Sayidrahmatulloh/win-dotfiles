local map = require("shared.keymap")
local M = {}

function M.setup()
  for _, key in ipairs({ "<C-/>", "<C-_>" }) do
    map({ "n", "t" }, key, function()
      require("standalone.features.terminal").toggle()
    end, "Toggle terminal panel")
  end
end

return M

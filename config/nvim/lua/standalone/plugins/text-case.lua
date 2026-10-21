local case_keys = {
  { "<leader>sc", "<cmd>TextCaseOpenTelescope<cr>", desc = "Text case picker" },
}
local cases = {
  wu = "to_upper_case",
  wl = "to_lower_case",
  wt = "to_title_case",
  ws = "to_snake_case",
  wc = "to_camel_case",
  wp = "to_pascal_case",
  wk = "to_dash_case",
}
for key, method in pairs(cases) do
  table.insert(case_keys, {
    "<leader>" .. key,
    function()
      require("textcase").current_word(method)
    end,
    desc = method:gsub("to_", ""):gsub("_", " "),
  })
end

return {
  "johmsalas/text-case.nvim",
  event = "VeryLazy",
  keys = case_keys,
}

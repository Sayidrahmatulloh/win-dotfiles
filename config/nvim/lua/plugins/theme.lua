return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = false,
      term_colors = true,
      color_overrides = { mocha = { base = "#0b1015", mantle = "#0b1015", crust = "#0b1015" } },
      styles = {
        comments = { "italic" },
        conditionals = { "italic" },
        keywords = { "italic" },
      },
      integrations = { snacks = true, blink_cmp = true, noice = true },
      custom_highlights = function(colors)
        return {
          WinBar = { fg = colors.text, bg = colors.base, style = { "bold", "italic" } },
          WinBarNC = { fg = colors.overlay1, bg = colors.base },
          WinSeparator = { fg = colors.surface0, bg = colors.base },
          NormalNC = { fg = colors.text, bg = colors.base },
          NormalFloat = { fg = colors.text, bg = colors.base },
          FloatBorder = { fg = colors.surface1, bg = colors.base },
          SnacksNormal = { fg = colors.text, bg = colors.base },
          SnacksNormalNC = { fg = colors.text, bg = colors.base },
          SnacksPicker = { fg = colors.text, bg = colors.base },
          SnacksPickerInput = { fg = colors.text, bg = colors.base },
          SnacksPickerList = { fg = colors.text, bg = colors.base },
          NoiceCmdlinePopup = { fg = colors.text, bg = colors.base },
          NoiceCmdlinePopupBorder = { fg = colors.surface1, bg = colors.base },
          Cursor = { fg = colors.base, bg = colors.green },
          BlinkCmpGhostText = { fg = colors.overlay1, style = { "italic" } },
        }
      end,
    },
  },
}

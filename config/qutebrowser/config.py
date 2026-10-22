"""Dark green qutebrowser setup for win-dotfiles."""

# Keep settings saved through :set; explicit values below take precedence.
config.load_autoconfig()

c.auto_save.session = True
c.window.hide_decoration = True
c.url.start_pages = ["about:blank"]
c.url.default_page = "about:blank"
c.url.searchengines = {
    "DEFAULT": "https://duckduckgo.com/?q={}",
    "g": "https://www.google.com/search?q={}",
    "gh": "https://github.com/search?q={}",
    "yt": "https://www.youtube.com/results?search_query={}",
}
c.fonts.default_family = ["CaskaydiaMono Nerd Font", "Cascadia Mono", "Consolas"]
c.fonts.default_size = "11pt"
c.tabs.show = "multiple"
c.tabs.position = "top"
c.tabs.padding = {"top": 8, "bottom": 8, "left": 12, "right": 12}
c.tabs.indicator.width = 3
c.tabs.title.format = "{index}: {current_title}"
c.statusbar.padding = {"top": 6, "bottom": 6, "left": 10, "right": 10}
c.completion.height = "35%"
c.completion.shrink = True
c.scrolling.smooth = True
c.downloads.position = "bottom"

bg = "#0b1015"
panel = "#151c24"
fg = "#cdd3dc"
muted = "#929dab"
border = "#293340"
accent = "#a6e22e"
error = "#f38ba8"
warning = "#f9e2af"

c.colors.webpage.bg = bg
c.colors.tabs.bar.bg = bg
c.colors.tabs.even.bg = panel
c.colors.tabs.odd.bg = panel
c.colors.tabs.even.fg = muted
c.colors.tabs.odd.fg = muted
c.colors.tabs.selected.even.bg = border
c.colors.tabs.selected.odd.bg = border
c.colors.tabs.selected.even.fg = accent
c.colors.tabs.selected.odd.fg = accent
c.colors.tabs.indicator.start = accent
c.colors.tabs.indicator.stop = accent
c.colors.tabs.indicator.error = error
c.colors.statusbar.normal.bg = bg
c.colors.statusbar.normal.fg = fg
c.colors.statusbar.insert.bg = accent
c.colors.statusbar.insert.fg = bg
c.colors.statusbar.command.bg = panel
c.colors.statusbar.command.fg = fg
c.colors.statusbar.command.private.bg = panel
c.colors.statusbar.command.private.fg = "#c4a7e7"
c.colors.statusbar.private.bg = panel
c.colors.statusbar.private.fg = "#c4a7e7"
c.colors.statusbar.caret.bg = border
c.colors.statusbar.caret.fg = accent
c.colors.statusbar.caret.selection.bg = accent
c.colors.statusbar.caret.selection.fg = bg
c.colors.statusbar.passthrough.bg = border
c.colors.statusbar.passthrough.fg = warning
c.colors.statusbar.url.fg = fg
c.colors.statusbar.url.success.http.fg = warning
c.colors.statusbar.url.success.https.fg = accent
c.colors.statusbar.url.error.fg = error
c.colors.statusbar.url.hover.fg = accent
c.colors.completion.fg = fg
c.colors.completion.even.bg = bg
c.colors.completion.odd.bg = panel
c.colors.completion.category.bg = border
c.colors.completion.category.fg = accent
c.colors.completion.category.border.top = border
c.colors.completion.category.border.bottom = border
c.colors.completion.item.selected.bg = border
c.colors.completion.item.selected.fg = fg
c.colors.completion.item.selected.border.top = accent
c.colors.completion.item.selected.border.bottom = accent
c.colors.completion.match.fg = accent
c.colors.completion.item.selected.match.fg = accent
c.colors.hints.bg = accent
c.colors.hints.fg = bg
c.hints.border = "1px solid #293340"
c.colors.hints.match.fg = "#395415"
c.colors.messages.error.bg = error
c.colors.messages.error.fg = bg
c.colors.messages.error.border = error
c.colors.messages.warning.bg = warning
c.colors.messages.warning.fg = bg
c.colors.messages.warning.border = warning
c.colors.messages.info.bg = panel
c.colors.messages.info.fg = fg
c.colors.messages.info.border = border
c.colors.prompts.bg = panel
c.colors.prompts.fg = fg
c.colors.prompts.border = "1px solid #293340"
c.colors.prompts.selected.bg = border
c.colors.downloads.bar.bg = bg
c.colors.downloads.start.bg = panel
c.colors.downloads.start.fg = fg
c.colors.downloads.stop.bg = accent
c.colors.downloads.stop.fg = bg
c.colors.downloads.error.bg = error
c.colors.downloads.error.fg = bg

config.bind("<Ctrl-j>", "tab-next")
config.bind("<Ctrl-k>", "tab-prev")
config.bind("<Ctrl-r>", "reload")
config.bind("<Space>r", "config-source")
config.bind("<Space>d", "config-cycle colors.webpage.darkmode.enabled")

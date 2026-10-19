# Dark green desktop

The default green theme uses these shared colors:

| Role | Color |
| --- | --- |
| Background | `#0B1015` |
| Panels and popups | `#151C24` |
| Text | `#CDD3DC` |
| Secondary text | `#AAB4C2` |
| Muted text | `#929DAB` |
| Active controls and cursor | `#A6E22E` |
| Borders and selection | `#293340` |
| Errors | `#F38BA8` |
| Warnings | `#F9E2AF` |

Applied to Windows Terminal, PowerShell prompt, PSReadLine, FZF, Neovim,
GlazeWM, the SolidJS Zebar bar, and keyboard/laptop widgets. Syntax and
diagnostic colors retain their meaning. Existing blue and purple desktop
variants remain available through the bar's theme button.

After editing bar sources, run `bun run build` in
`widgets/zebar/attaquer-solid-ts`, then restart Zebar. Terminal settings can
be restored with `./scripts/install/terminal.ps1`; reopen PowerShell and
Neovim to load their updated configuration.

The bar uses the `zebar.theme.v2` preference to select green on the first
launch of this palette. Later user selections persist normally.

Workspace VS Code colors are also configured in the locally ignored
`.vscode/settings.json`; they are not part of a fresh clone.

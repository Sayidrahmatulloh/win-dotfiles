# Quiet Velvet

A calm, compact 50px desktop bar with muted violet accents. Workspace buttons,
clock, media controls and system readings use consistent SVG icons, so no icon
font download or Nerd Font is required.

## Build and preview

From the repository root:

```powershell
bun install --cwd widgets/zebar/quiet-velvet --frozen-lockfile
bun run --cwd widgets/zebar/quiet-velvet build
bun run --cwd widgets/zebar/quiet-velvet dev --host 127.0.0.1
```

Open the local URL with `?preview` to see sample data without connecting to
Zebar or executing desktop commands. Real provider and shell behavior requires
Zebar. Settings work inline within the 50px window; press Escape to close them.
Media, search, shortcuts and active app visibility are saved locally. Narrow
windows progressively hide secondary readings and controls.

`src/config.defaults.js` supplies portable shortcut executable names. An optional,
Git-ignored `src/config.js` default export can override them. Media uses Windows
media sessions, including Spotify when available, with no credentials or polling.

Zebar v3 reads `zpack.json`; select `quiet-velvet`, `top-bar`, `default` in Zebar
to try this optional widget. The repository startup selection is unchanged.
The old `main.zebar.json` is retained for reference and is not used by Zebar v3.

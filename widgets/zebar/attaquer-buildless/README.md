# Attaquer (formerly buildless)

This variant uses a prebuilt React bundle. Zebar loads `dist/index.html`.
AHK v2 and GlazeWM are needed for Windows shortcut buttons.

From the repository root:

```powershell
bun install --cwd widgets/zebar/attaquer-buildless --frozen-lockfile
./tools/prepare-ci-font.ps1 -FontDirectory ./widgets/zebar/attaquer-buildless/fonts
bun run --cwd widgets/zebar/attaquer-buildless build
```

`index.jsx` contains the provider connection and panel layout. Pure status and
icon helpers live in `src/status.jsx`; command handling lives in `src/actions.js`.

# Bibata Modern — Zebar colors

`Bibata-Modern-Zebar.zip` contains 51 unmodified Bibata Modern cursors
in standard Amber, Ice and Classic colors, plus GPL-3.0 LICENSE and attribution.
Derived from [ful1e5/Bibata_Cursor v2.0.7](https://github.com/ful1e5/Bibata_Cursor/releases/tag/v2.0.7),
Bibata-Modern-{Amber,Ice,Classic}-Windows.zip, Regular variants. Copyright Abdulkaiz Khatri
and Bibata contributors; licensed under GPL-3.0 (see LICENSE).
The original `.cur` and `.ani` files are preserved byte for byte.
`themes/themes.json` maps green to Amber, blue to Ice and purple to Classic.
There is no custom recoloring or Python dependency for installation.

`install.ps1` runs this stage automatically. The ZIP is extracted into
`%LOCALAPPDATA%\win-dotfiles\cursors\Bibata-Modern-Zebar` and activated for
the current user. No download, Python, INF installer or elevation is required.
Rerunning setup repairs files and preserves the currently selected Bibata color.
Zebar uses the installed files when switching themes.

Standalone installation from the repository:

```powershell
./scripts/install/cursors.ps1 -Theme green
```

To update the bundle, copy the 17 standard Windows cursor roles from each
official Regular archive into `amber/`, `ice/` and `classic/` directories,
then ZIP those directories together with LICENSE and this README.

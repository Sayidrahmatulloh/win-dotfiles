# Font archives

Font ZIP files live here; installation code is in `scripts/install/fonts.ps1`.
Nerd Fonts package names are configured separately in `setup.json`.

Setup opens each ZIP in a private temporary directory, registers `.ttf` and
`.otf` files for the current user, and repairs missing registry entries on rerun.
Keep each font's original licensing information inside its archive.

Local MonoLisa and Dank Mono archives remain excluded by `.gitignore`.
Moving the repository structure preserves those local files without publishing them.

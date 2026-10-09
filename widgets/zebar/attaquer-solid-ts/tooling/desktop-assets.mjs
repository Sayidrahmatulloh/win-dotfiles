import {cpSync, existsSync, mkdirSync, readFileSync} from 'node:fs';
import {resolve, dirname} from 'node:path';
import {fileURLToPath} from 'node:url';

const widget = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const root = resolve(widget, '../../..');

export function desktopAssets() {
  let output;
  return {
    name: 'desktop-assets',
    configResolved(config) { output = resolve(config.root, config.build.outDir, 'desktop'); },
    closeBundle() {
      const catalog = JSON.parse(readFileSync(resolve(root, 'themes/themes.json'), 'utf8'));
      const files = ['themes/themes.json', 'assets/cursors/Bibata-Modern-Zebar.zip',
        'scripts/theme/ThemeConfig.ps1', 'scripts/theme/ApplyTheme.ps1',
        'scripts/theme/SetCursor.ps1', 'scripts/theme/SetWallpaper.ps1',
        ...catalog.themes.map(theme => theme.wallpaper)];
      for (const file of files) {
        if (!existsSync(resolve(root, file))) throw new Error(`Missing desktop asset: ${file}`);
        const destination = resolve(output, file);
        mkdirSync(dirname(destination), {recursive: true});
        cpSync(resolve(root, file), destination);
      }
    },
  };
}

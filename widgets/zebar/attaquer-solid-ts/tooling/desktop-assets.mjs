import { cpSync, existsSync, mkdirSync, readFileSync, readdirSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const widget = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const root = resolve(widget, '../../..');

export function desktopAssets() {
  let output;
  return {
    name: 'desktop-assets',
    configResolved(config) {
      output = resolve(config.root, config.build.outDir, 'desktop');
    },
    closeBundle() {
      const catalog = JSON.parse(readFileSync(resolve(root, 'themes/themes.json'), 'utf8'));
      const files = [
        'themes/themes.json',
        'assets/cursors/Bibata-Modern-Zebar.zip',
        ...readdirSync(resolve(root, 'scripts/theme'), { withFileTypes: true })
          .filter((entry) => entry.isFile())
          .map((entry) => `scripts/theme/${entry.name}`),
        ...catalog.themes.map((theme) => theme.wallpaper),
      ];
      for (const file of files) {
        if (!existsSync(resolve(root, file))) throw new Error(`Missing desktop asset: ${file}`);
        const destination = resolve(output, file);
        mkdirSync(dirname(destination), { recursive: true });
        cpSync(resolve(root, file), destination);
      }
    },
  };
}

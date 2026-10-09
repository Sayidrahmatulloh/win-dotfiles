import {defineConfig} from 'vite';
import solid from 'vite-plugin-solid';
import {desktopAssets} from './tooling/desktop-assets.mjs';
export default defineConfig({plugins:[solid(),desktopAssets()],base:'./',build:{target:'es2022'}});

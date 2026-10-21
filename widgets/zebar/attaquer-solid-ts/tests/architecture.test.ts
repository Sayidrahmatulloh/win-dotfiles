import { describe, expect, test } from 'bun:test';
import { readdirSync, readFileSync } from 'node:fs';
import { dirname, extname, resolve } from 'node:path';
import ts from 'typescript';

const sourceRoot = resolve(import.meta.dir, '../src');
function sources(directory: string): string[] {
  return readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const path = resolve(directory, entry.name);
    return entry.isDirectory() ? sources(path) : /\.tsx?$/.test(path) ? [path] : [];
  });
}

describe('source architecture', () => {
  test('relative TypeScript imports resolve and services stay independent of components', () => {
    for (const file of sources(sourceRoot)) {
      const tree = ts.createSourceFile(file, readFileSync(file, 'utf8'), ts.ScriptTarget.Latest);
      for (const node of tree.statements) {
        if (!ts.isImportDeclaration(node) || !ts.isStringLiteral(node.moduleSpecifier)) continue;
        const specifier = node.moduleSpecifier.text;
        if (!specifier.startsWith('.') || ['.css', '.json'].includes(extname(specifier))) continue;
        const target = ts.resolveModuleName(
          specifier,
          file,
          { moduleResolution: ts.ModuleResolutionKind.Bundler },
          ts.sys,
        ).resolvedModule;
        expect(target, `${file} imports missing module ${specifier}`).toBeDefined();
        const normalized = resolve(dirname(file), specifier).replaceAll('\\', '/');
        const layer = file.replaceAll('\\', '/');
        if (layer.includes('/services/') || layer.includes('/shared/')) {
          expect(normalized.includes('/components/'), `${file} depends on a UI component`).toBe(
            false,
          );
        }
        if (layer.includes('/shared/')) {
          expect(
            normalized.includes('/services/'),
            `${file} makes shared code depend on a service`,
          ).toBe(false);
        }
      }
    }
  });
});

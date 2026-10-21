import { describe, expect, test } from 'bun:test';
import { createWidgetActions } from '../src/services/desktop/widgetActions';

describe('direct widget actions', () => {
  test('startup and repeated clicks share a single executable lookup', async () => {
    let lookups = 0;
    const actions = createWidgetActions(
      async () => {
        lookups++;
        return 'D:\\Custom Scoop\\AutoHotkey64.exe';
      },
      () => 'D:\\Widget With Spaces\\assets\\scripts',
    );
    await Promise.all([actions.prepare(), actions.prepare()]);
    expect(await actions.command('OpenStartMenu')).toBe(
      'shell-exec cmd.exe /d /s /c ""D:/Custom Scoop/AutoHotkey64.exe" "D:/Widget With Spaces/assets/scripts/OpenStartMenu.ahk""',
    );
    expect(await actions.command('OpenWindowsSearch')).toContain('OpenWindowsSearch.ahk');
    expect(await actions.command('FocusWindow', 123456)).toEndWith('FocusWindow.ahk" 123456"');
    expect(lookups).toBe(1);
  });
  test('normal installations launch AutoHotkey directly without a shell startup', async () => {
    const actions = createWidgetActions(
      async () => 'C:/Users/dev/scoop/apps/autohotkey/current/v2/AutoHotkey64.exe',
      () => 'D:/scripts',
    );
    expect(await actions.command('OpenStartMenu')).toBe(
      'shell-exec C:/Users/dev/scoop/apps/autohotkey/current/v2/AutoHotkey64.exe "D:/scripts/OpenStartMenu.ahk"',
    );
  });
  test('a failed lookup can retry instead of caching failure', async () => {
    let lookups = 0;
    const actions = createWidgetActions(
      async () => {
        if (++lookups === 1) throw new Error('temporarily unavailable');
        return 'D:/AutoHotkey64.exe';
      },
      () => 'D:/scripts',
    );
    await expect(actions.prepare()).rejects.toThrow('temporarily unavailable');
    expect(await actions.command('OpenStartMenu')).toContain('D:/AutoHotkey64.exe');
    expect(lookups).toBe(2);
  });
  test('invalid handles and quoted paths never reach command execution', async () => {
    const actions = createWidgetActions(
      async () => 'D:/AutoHotkey64.exe',
      () => 'D:/scripts',
    );
    await expect(actions.command('FocusWindow')).rejects.toThrow('valid window handle');
    await expect(actions.command('FocusWindow', -1)).rejects.toThrow('valid window handle');
    const unsafe = createWidgetActions(
      async () => 'D:/bad"path.exe',
      () => 'D:/scripts',
    );
    await expect(unsafe.command('OpenStartMenu')).rejects.toThrow('Invalid widget');
  });
});

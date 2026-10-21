export type WidgetAction =
  'OpenWindowsSearch' | 'OpenStartMenu' | 'OpenActionCenter' | 'FocusWindow';

function normalizePath(path: string) {
  if (!/^[A-Za-z]:[\\/]/.test(path) || /["\r\n%]/.test(path))
    throw new Error('Invalid widget executable or script path');
  return path.replace(/\\/g, '/');
}

export function createWidgetActions(
  resolveExecutable: () => Promise<string>,
  scriptDirectory: () => string,
) {
  let executable: Promise<string> | undefined;
  function prepare() {
    if (!executable) {
      executable = resolveExecutable()
        .then(normalizePath)
        .catch((error) => {
          executable = undefined;
          throw error;
        });
    }
    return executable;
  }
  async function command(action: WidgetAction, windowHandle?: number) {
    if (!['OpenWindowsSearch', 'OpenStartMenu', 'OpenActionCenter', 'FocusWindow'].includes(action))
      throw new Error('Unknown widget action');
    if (
      action === 'FocusWindow' &&
      (windowHandle === undefined || !Number.isSafeInteger(windowHandle) || windowHandle < 0)
    ) {
      throw new Error('A valid window handle is required');
    }
    const path = await prepare();
    const script = normalizePath(scriptDirectory() + '/' + action + '.ahk');
    const handle = action === 'FocusWindow' ? ` ${windowHandle}` : '';
    // GlazeWM rejects quotes around the executable. Only installations with
    // spaces in the executable path need the lightweight cmd.exe wrapper.
    if (/\s/.test(path)) return `shell-exec cmd.exe /d /s /c ""${path}" "${script}"${handle}"`;
    return `shell-exec ${path} "${script}"${handle}`;
  }
  return { prepare, command };
}

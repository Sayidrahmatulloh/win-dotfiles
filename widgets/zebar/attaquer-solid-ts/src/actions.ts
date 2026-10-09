import { createSignal } from 'solid-js';
import { currentWidget, shellExec, type GlazeWmOutput } from 'zebar';
import { createWidgetActions, type WidgetAction } from './widgetActions';
export const [actionError, setActionError] = createSignal('');
export async function safely(action: () => unknown, label = 'Action') {
  try { await action(); setActionError(''); }
  catch (error) { console.error(label, error); setActionError(label + ' failed. Check Zebar logs.'); }
}
export async function runWm(wm: GlazeWmOutput | null | undefined, command: string) {
  return safely(async () => {
    if (!wm) throw new Error('GlazeWM is not connected');
    await wm.runCommand(command);
  }, 'GlazeWM command');
}
const scriptDirectory = () => currentWidget().htmlPath.replace(/\\/g, '/').replace(/\/[^/]*$/, '/assets/scripts');
const widgetActions = createWidgetActions(async () => {
  const args = ['-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'Bypass', '-WindowStyle', 'Hidden', '-File', scriptDirectory() + '/InvokeWidgetAction.ps1', '-Action', 'ResolveAutoHotkey'];
  const result = await shellExec('powershell.exe', args);
  if (result.code !== 0) throw new Error(result.stderr || 'AutoHotkey resolution failed');
  const resolved: unknown = JSON.parse(result.stdout.trim());
  if (!resolved || typeof resolved !== 'object' || !('executable' in resolved) || typeof resolved.executable !== 'string') throw new Error('AutoHotkey path was not returned');
  return resolved.executable;
}, scriptDirectory);
export function prepareWidgetActions() { return safely(() => widgetActions.prepare(), 'AutoHotkey'); }
export async function runWidgetAction(wm: GlazeWmOutput | null | undefined, action: WidgetAction, windowHandle?: number) {
  return safely(async () => {
    if (!wm) throw new Error('GlazeWM is not connected');
    await wm.runCommand(await widgetActions.command(action, windowHandle));
  }, action);
}

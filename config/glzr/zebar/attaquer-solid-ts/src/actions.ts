import { createSignal } from 'solid-js';
import type { GlazeWmOutput } from 'zebar';
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

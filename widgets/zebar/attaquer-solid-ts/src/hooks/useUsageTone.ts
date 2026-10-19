import { createEffect, createMemo, createSignal, onCleanup } from 'solid-js';

type UsageTone = 'normal' | 'warning' | 'critical';
const WARNING_DELAY_MS = 10000;

export function useUsageTone(read: () => number | undefined) {
  const desired = createMemo<UsageTone>(() => {
    const value = read();
    if (value == null || !Number.isFinite(value)) return 'normal';
    if (value >= 95) return 'critical';
    return value >= 85 ? 'warning' : 'normal';
  });
  const [tone, setTone] = createSignal<UsageTone>('normal');
  createEffect(() => {
    const target = desired();
    if (target === 'normal') {
      setTone('normal');
      return;
    }
    const timer = setTimeout(() => setTone(target), WARNING_DELAY_MS);
    onCleanup(() => clearTimeout(timer));
  });
  return tone;
}

import { afterEach, describe, expect, mock, test } from 'bun:test';
import { createRoot } from 'solid-js';

let group: ReturnType<typeof fakeGroup>;
function fakeGroup() {
  let outputListener: (output: object) => void;
  let errorListener: (errors: object) => void;
  return {
    outputMap: { battery: null },
    errorMap: {} as Record<string, unknown>,
    raw: { battery: { restart: mock(async () => {}) } },
    stopAll: mock(async () => {}),
    onOutput(callback: typeof outputListener) {
      outputListener = callback;
    },
    onError(callback: typeof errorListener) {
      errorListener = callback;
    },
    fail(errors: Record<string, unknown>) {
      this.errorMap = errors;
      errorListener(errors);
    },
    output(battery: object) {
      this.errorMap = {};
      outputListener({ battery });
    },
  };
}
mock.module('zebar', () => ({ createProviderGroup: () => group }));
const { useProviders } = await import('../src/hooks/useProviders');

const originalSetTimeout = globalThis.setTimeout;
const originalClearTimeout = globalThis.clearTimeout;
let dispose: (() => void) | undefined;
afterEach(() => {
  dispose?.();
  dispose = undefined;
  globalThis.setTimeout = originalSetTimeout;
  globalThis.clearTimeout = originalClearTimeout;
});

function mount() {
  group = fakeGroup();
  const pending = new Map<number, () => Promise<void>>();
  let nextId = 0;
  globalThis.setTimeout = ((callback: () => Promise<void>, delay: number) => {
    expect(delay).toBe(10000);
    pending.set(++nextId, callback);
    return nextId;
  }) as unknown as typeof setTimeout;
  globalThis.clearTimeout = ((id: number) => {
    pending.delete(id);
  }) as unknown as typeof clearTimeout;
  const state = createRoot((cleanup) => {
    dispose = cleanup;
    return useProviders();
  });
  const tick = async () => {
    const [id, callback] = pending.entries().next().value!;
    pending.delete(id);
    await callback();
  };
  return { state, pending, tick };
}

describe('provider lifecycle', () => {
  test('battery recovery is deduplicated and stops after three attempts', async () => {
    const { state, pending, tick } = mount();
    group.fail({ battery: 'os error 433' });
    group.fail({ battery: 'os error 433' });
    expect(pending.size).toBe(1);
    expect(state.error()).toBe('');
    for (let attempt = 0; attempt < 3; attempt++) await tick();
    expect(group.raw.battery.restart).toHaveBeenCalledTimes(3);
    expect(pending.size).toBe(0);
    expect(state.error()).toContain('battery: os error 433');
  });

  test('recovery cancels when data returns and other errors remain visible', () => {
    const { state, pending } = mount();
    group.fail({ battery: 'os error 433', cpu: 'offline' });
    expect(state.error()).toContain('cpu: offline');
    group.output({ chargePercent: 80 });
    expect(pending.size).toBe(0);
    expect(state.error()).toBe('');
    group.fail({ cpu: 'offline' });
    state.dismissError();
    expect(state.error()).toBe('');
  });

  test('disposal stops providers, cancels retry and ignores late events', () => {
    const { state, pending } = mount();
    group.fail({ battery: 'os error 433' });
    dispose!();
    dispose = undefined;
    expect(group.stopAll).toHaveBeenCalledTimes(1);
    expect(pending.size).toBe(0);
    group.fail({ cpu: 'late failure' });
    expect(state.error()).toBe('');
  });
});

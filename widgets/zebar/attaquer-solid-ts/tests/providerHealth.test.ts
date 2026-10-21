import { describe, expect, test } from 'bun:test';
import { isBatteryDeviceMissing, providerErrorMessage } from '../src/services/providers/health';

describe('provider health', () => {
  test('only missing battery errors are hidden during recovery', () => {
    expect(providerErrorMessage({ battery: 'os error 433', cpu: 'offline' }, 0)).toBe(
      'Data source unavailable — cpu: offline',
    );
    expect(providerErrorMessage({ battery: 'permission denied' }, 0)).toContain(
      'battery: permission denied',
    );
    expect(providerErrorMessage({ battery: 'os error 433' }, 3)).toContain('battery: os error 433');
  });

  test('missing-device recognition does not hide other Windows errors', () => {
    expect(isBatteryDeviceMissing(new Error('Windows: OS ERROR 433'))).toBe(true);
    expect(isBatteryDeviceMissing('os error 4330')).toBe(false);
    expect(providerErrorMessage({ cpu: null, memory: undefined }, 0)).toBe('');
  });
});

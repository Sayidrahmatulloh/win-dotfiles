export const BATTERY_RETRY_LIMIT = 3;

export function isBatteryDeviceMissing(error: unknown) {
  return /\bos error 433\b/i.test(String(error));
}

export function providerErrorMessage(errors: Record<string, unknown>, batteryRetries: number) {
  const failures = Object.entries(errors)
    .filter(
      ([name, error]) =>
        error != null &&
        !(
          name === 'battery' &&
          isBatteryDeviceMissing(error) &&
          batteryRetries < BATTERY_RETRY_LIMIT
        ),
    )
    .map(([name, error]) => `${name}: ${String(error)}`);
  return failures.length ? `Data source unavailable — ${failures.join('; ')}` : '';
}

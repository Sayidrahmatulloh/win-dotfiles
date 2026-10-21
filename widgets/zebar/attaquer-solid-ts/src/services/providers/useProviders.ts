import { createSignal, onCleanup } from 'solid-js';
import { createStore } from 'solid-js/store';
import { createProviderGroup } from 'zebar';
import { BATTERY_RETRY_LIMIT, isBatteryDeviceMissing, providerErrorMessage } from './health';

const BATTERY_RETRY_DELAY_MS = 10000;

export function useProviders() {
  const providers = createProviderGroup({
    glazewm: { type: 'glazewm' },
    cpu: { type: 'cpu', refreshInterval: 5000 },
    memory: { type: 'memory', refreshInterval: 5000 },
    network: { type: 'network', refreshInterval: 2000 },
    battery: { type: 'battery', refreshInterval: 10000 },
    date: { type: 'date', formatting: 'HH:mm ccc d LLLL y' },
    media: { type: 'media' },
    audio: { type: 'audio' },
  });
  const [output, setOutput] = createStore(providers.outputMap);
  const [error, setError] = createSignal('');
  let batteryRetry: ReturnType<typeof setTimeout> | undefined;
  let batteryRetries = 0;
  let disposed = false;

  function updateError() {
    setError(providerErrorMessage(providers.errorMap, batteryRetries));
  }

  function recoverBattery() {
    if (
      !isBatteryDeviceMissing(providers.errorMap.battery) ||
      batteryRetry !== undefined ||
      batteryRetries >= BATTERY_RETRY_LIMIT
    )
      return;
    batteryRetry = setTimeout(async () => {
      batteryRetry = undefined;
      if (disposed || !isBatteryDeviceMissing(providers.errorMap.battery)) return;
      batteryRetries++;
      try {
        await providers.raw.battery.restart();
      } catch (failure) {
        console.error('Battery reconnect', failure);
      }
      if (!disposed) {
        updateError();
        recoverBattery();
      }
    }, BATTERY_RETRY_DELAY_MS);
  }

  providers.onOutput((outputMap) => {
    if (disposed) return;
    setOutput({ ...outputMap, battery: providers.errorMap.battery ? null : outputMap.battery });
    if (outputMap.battery && !providers.errorMap.battery) {
      batteryRetries = 0;
      clearTimeout(batteryRetry);
      batteryRetry = undefined;
    }
    updateError();
  });
  providers.onError((errors) => {
    if (disposed) return;
    console.error('Provider', errors);
    if (errors.battery) setOutput('battery', null);
    recoverBattery();
    updateError();
  });

  onCleanup(() => {
    disposed = true;
    clearTimeout(batteryRetry);
    void providers.stopAll().catch(console.error);
  });

  return { output, error, dismissError: () => setError('') };
}

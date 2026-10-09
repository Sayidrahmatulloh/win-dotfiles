import { createSignal, onCleanup, onMount } from 'solid-js';
import { actionError, setActionError, prepareWidgetActions } from './actions';
/* @refresh reload */
import "./index.css"
import { render } from "solid-js/web"
import { createStore } from "solid-js/store"
import * as zebar from "zebar"
import WindowsButton from "./Buttons/WindowsButton"
import SearchButton from "./Buttons/SearchButton"
import Workspaces from "./Workspaces/Workspaces"
import TilingBinding from "./TilingBinding/TilingBinding"
import VolumeStatus from "./VolumeStatus/VolumeStatus"
import MediaStatus from "./Media/MediaStatus"
import CpuStatus from "./CpuStatus/CpuStatus"
import MemoryStatus from "./MemoryStatus/MemoryStatus"

import NetworkStatus from "./NetworkStatus/NetworkStatus"
import BatteryStatus from "./BatteryStatus/BatteryStatus"
import TimeStatus from "./Time/TimeStatus"

import "./compact.css";
import ThemeSwitcher from "./ThemeSwitcher/ThemeSwitcher";
import Tooltip from './Tooltip';

const providers = zebar.createProviderGroup({
  glazewm: { type: "glazewm" },
  cpu: { type: "cpu", refreshInterval: 5000 },
  memory: { type: "memory", refreshInterval: 5000 },
  network: { type: "network", refreshInterval: 2000 },
  battery: { type: "battery", refreshInterval: 10000 },
  date: { type: "date", formatting: "HH:mm ccc d LLLL y" },
  media: { type: "media" },
  audio: { type: "audio" },
})

render(() => <App />, document.getElementById("root")!)

function App() {
  onMount(() => { void prepareWidgetActions(); });
  const [output, setOutput] = createStore(providers.outputMap)

  const [providerError, setProviderError] = createSignal('');
  const isBatteryDeviceMissing = (error: unknown) => /\bos error 433\b/i.test(String(error));
  let batteryRetry: ReturnType<typeof setTimeout> | undefined;
  let batteryRetries = 0;
  const recoverBattery = () => {
    if (!isBatteryDeviceMissing(providers.errorMap.battery) || batteryRetry || batteryRetries >= 3) return;
    batteryRetry = setTimeout(async () => {
      batteryRetry = undefined;
      if (disposed || !isBatteryDeviceMissing(providers.errorMap.battery)) return;
      batteryRetries++;
      try { await providers.raw.battery.restart(); }
      catch (error) { console.error('Battery reconnect', error); }
      if (!disposed) { updateProviderError(); recoverBattery(); }
    }, 10000);
  };
  const updateProviderError = () => {
    const failures = Object.entries(providers.errorMap)
      .filter(([name, error]) => error != null && !(name === "battery" && isBatteryDeviceMissing(error) && batteryRetries < 3))
      .map(([name, error]) => `${name}: ${String(error)}`);
    setProviderError(failures.length ? `Data source unavailable — ${failures.join('; ')}` : '');
  };
  const visibleError = () => [actionError(), providerError()].filter(Boolean).join(' | ');
  let disposed = false;
  providers.onOutput(outputMap => {
    if (!disposed) {
      setOutput({ ...outputMap, battery: providers.errorMap.battery ? null : outputMap.battery });
      if (outputMap.battery && !providers.errorMap.battery) {
        batteryRetries = 0;
        clearTimeout(batteryRetry);
        batteryRetry = undefined;
      }
      updateProviderError();
    }
  });
  providers.onError(errors => {
    if (!disposed) { console.error('Provider', errors); if (errors.battery) setOutput('battery', null); recoverBattery(); updateProviderError(); }
  });
  onCleanup(() => { disposed = true; clearTimeout(batteryRetry); void providers.stopAll().catch(console.error); });

  return (
    <div class="app">
      <Tooltip />
      {visibleError() && <button type="button" class="action-error" role="status" data-tooltip={visibleError()} aria-label={visibleError() + " Click to dismiss."} onClick={() => { setActionError(""); setProviderError(""); }}>!</button>}
      <div class="left">
        <WindowsButton glazewm={output.glazewm} />
        <SearchButton glazewm={output.glazewm} />
        <Workspaces glazewm={output.glazewm} />
        <TilingBinding glazewm={output.glazewm} />
        <ThemeSwitcher />
        <MediaStatus media={output.media} />
      </div>
      <div class="center" aria-hidden="true" />
      <div class="right">
        <CpuStatus cpu={output.cpu} glazewm={output.glazewm} />
        <MemoryStatus memory={output.memory} />
        <NetworkStatus network={output.network} glazewm={output.glazewm} />
        <VolumeStatus audio={output.audio} glazewm={output.glazewm} />
        <BatteryStatus battery={output.battery} />
        <TimeStatus date={output.date} />
      </div>
    </div>
  )
}

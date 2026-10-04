import { onCleanup } from 'solid-js';
import { actionError, setActionError } from './actions';
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
  const [output, setOutput] = createStore(providers.outputMap)

  let disposed = false;
  providers.onOutput(outputMap => { if (!disposed) setOutput(outputMap); });
  providers.onError(error => { if (!disposed) { console.error('Provider', error); setActionError('A data source is unavailable. Check Zebar logs.'); } });
  onCleanup(() => { disposed = true; void providers.stopAll().catch(console.error); });

  return (
    <div class="app">
      <Tooltip />
      {actionError() && <button type="button" class="action-error" role="status" title={actionError()} aria-label={actionError() + " Click to dismiss."} onClick={() => setActionError("")}>!</button>}
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

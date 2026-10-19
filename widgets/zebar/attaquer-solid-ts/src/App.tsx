import { onMount } from 'solid-js';
import { actionError, setActionError, prepareWidgetActions } from './actions';
import { useProviders } from './hooks/useProviders';
import WindowsButton from './Buttons/WindowsButton';
import SearchButton from './Buttons/SearchButton';
import Workspaces from './Workspaces/Workspaces';
import TilingBinding from './TilingBinding/TilingBinding';
import VolumeStatus from './VolumeStatus/VolumeStatus';
import MediaStatus from './Media/MediaStatus';
import CpuStatus from './CpuStatus/CpuStatus';
import MemoryStatus from './MemoryStatus/MemoryStatus';

import NetworkStatus from './NetworkStatus/NetworkStatus';
import BatteryStatus from './BatteryStatus/BatteryStatus';
import TimeStatus from './Time/TimeStatus';
import './compact.css';
import ThemeSwitcher from './ThemeSwitcher/ThemeSwitcher';
import Tooltip from './Tooltip';

export default function App() {
  const { output, error: providerError, dismissError } = useProviders();
  const visibleError = () => [actionError(), providerError()].filter(Boolean).join(' | ');
  onMount(() => {
    void prepareWidgetActions();
  });
  return (
    <div class="app">
      <Tooltip />
      {visibleError() && (
        <button
          type="button"
          class="action-error"
          role="status"
          data-tooltip={visibleError()}
          aria-label={visibleError() + ' Click to dismiss.'}
          onClick={() => {
            setActionError('');
            dismissError();
          }}
        >
          !
        </button>
      )}
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
  );
}

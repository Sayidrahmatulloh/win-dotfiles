import { onMount } from 'solid-js';
import { actionError, setActionError, prepareWidgetActions } from './services/desktop/actions';
import { useProviders } from './services/providers/useProviders';
import WindowsButton from './components/Buttons/WindowsButton';
import SearchButton from './components/Buttons/SearchButton';
import Workspaces from './components/Workspaces/Workspaces';
import TilingBinding from './components/TilingBinding/TilingBinding';
import VolumeStatus from './components/VolumeStatus/VolumeStatus';
import MediaStatus from './components/Media/MediaStatus';
import CpuStatus from './components/CpuStatus/CpuStatus';
import MemoryStatus from './components/MemoryStatus/MemoryStatus';

import NetworkStatus from './components/NetworkStatus/NetworkStatus';
import BatteryStatus from './components/BatteryStatus/BatteryStatus';
import TimeStatus from './components/Time/TimeStatus';
import './styles/compact.css';
import ThemeSwitcher from './components/ThemeSwitcher/ThemeSwitcher';
import Tooltip from './components/Tooltip/Tooltip';

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

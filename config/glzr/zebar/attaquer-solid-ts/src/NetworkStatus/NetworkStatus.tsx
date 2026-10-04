import StatusIcon from '../StatusIcon';
import { runWm } from '../actions';
import "./style.css";
import { Component } from "solid-js";
import { NetworkOutput } from "zebar";
import { GlazeWmOutput } from "zebar";
import { useAnimatedClick } from "../hooks/useAnimatedClick";

interface NetworkStatusProps {
  network: NetworkOutput | null;
  glazewm: GlazeWmOutput | null;
}

const NetworkStatus: Component<NetworkStatusProps> = (props) => {
  const { isActive, handleClick } = useAnimatedClick();

  const handleOpenActionCenterClick = () => {
    handleClick();
    runWm(props.glazewm, 
      "shell-exec %userprofile%/scoop/apps/autohotkey/current/v2/AutoHotkey64.exe %userprofile%/.glzr/zebar/attaquer-solid-ts/dist/assets/scripts/OpenActionCenter.ahk",
    );
  };
  const getNetworkIcon = () => <StatusIcon name={props.network?.defaultInterface?.type === 'ethernet' ? 'ethernet' : props.network?.defaultInterface?.type === 'wifi' ? 'wifi' : 'offline'}/>;
  return (
    <button data-tooltip={props.network?.defaultInterface ? 'Download: ' + (props.network.traffic?.received.siValue ?? '—') + ' ' + (props.network.traffic?.received.siUnit ?? '') + ' · Upload: ' + (props.network.traffic?.transmitted.siValue ?? '—') + ' ' + (props.network.traffic?.transmitted.siUnit ?? '') : 'Offline / no interface'} type="button" aria-label="Network quick settings"
      class={`network ${isActive() ? "clicked-animated" : ""}`}
      onClick={handleOpenActionCenterClick}
    >
      <span class="content">
        {getNetworkIcon()}
        <div class="labels">
          <span class="label">
            <span class="ii"></span>
            <span class="net-line">
              {props.network?.traffic?.received.siValue ?? '—'}{" "}
              {props.network?.traffic?.received.siUnit}
            </span>
          </span>
          <span class="label">
            <span class="ii"></span>
            <span class="net-line">
              {props.network?.traffic?.transmitted.siValue ?? '—'}{" "}
              {props.network?.traffic?.transmitted.siUnit}
            </span>
          </span>
        </div>
      </span>
    </button>
  );
};

export default NetworkStatus;


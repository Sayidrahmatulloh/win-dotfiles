import StatusIcon from '../StatusIcon';
import { durationText, numberText } from '../format';
import { Component } from 'solid-js';
import { BatteryOutput } from 'zebar';

interface BatteryStatusProps {
  battery: BatteryOutput | null;
}

const BatteryStatus: Component<BatteryStatusProps> = (props) => {
  const getBatteryIcon = () => (
    <StatusIcon
      name="battery"
      level={props.battery?.chargePercent}
      charging={props.battery?.isCharging}
    />
  );
  const BatteryTime = () =>
    props.battery?.state === 'charging'
      ? 'Charging: ' + durationText(props.battery.timeTillFull)
      : props.battery?.state === 'discharging'
        ? durationText(props.battery.timeTillEmpty)
        : (props.battery?.state ?? 'Battery unavailable');
  return (
    <div
      hidden={!props.battery}
      classList={{
        template: true,
        battery: true,
        'usage-warning':
          !props.battery?.isCharging &&
          (props.battery?.chargePercent ?? 100) < 20 &&
          (props.battery?.chargePercent ?? 100) >= 10,
        'usage-critical': !props.battery?.isCharging && (props.battery?.chargePercent ?? 100) < 10,
      }}
      data-tooltip={BatteryTime()}
    >
      {getBatteryIcon()}
      {numberText(props.battery?.chargePercent)}%
    </div>
  );
};

export default BatteryStatus;

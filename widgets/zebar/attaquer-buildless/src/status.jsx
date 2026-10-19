import React from 'react';

export function getCpuUsageRate(cpuOutput) {
  if (cpuOutput.usage > 90) return 'extreme-usage';
  else if (cpuOutput.usage > 65) return 'high-usage';
  else if (cpuOutput.usage > 30) return 'medium-usage';
  else return 'low-usage';
}

export function getMemoryUsageRate(memoryOutput) {
  if (memoryOutput.usage > 90) return 'extreme-usage';
  else if (memoryOutput.usage > 65) return 'high-usage';
  else if (memoryOutput.usage > 45) return 'medium-usage';
  else return 'low-usage';
}

export function getNetworkIcon(networkOutput) {
  switch (networkOutput.defaultInterface?.type) {
    case 'ethernet':
      return (
        <img
          alt=""
          src="./icons/icons8-wired-network-32.png"
          className="i-eth"
          width="20"
          height="20"
        ></img>
      );
    case 'wifi':
      if (networkOutput.defaultGateway?.signalStrength >= 75) {
        return (
          <img
            alt=""
            src="./icons/icons8-wifi-3-32.png"
            className="i-wifi"
            width="20"
            height="20"
          ></img>
        );
      } else if (networkOutput.defaultGateway?.signalStrength >= 45) {
        return (
          <img
            alt=""
            src="./icons/icons8-wifi-2-32.png"
            className="i-wifi"
            width="20"
            height="20"
          ></img>
        );
      } else if (networkOutput.defaultGateway?.signalStrength >= 5) {
        return (
          <img
            alt=""
            src="./icons/icons8-wifi-1-32.png"
            className="i-wifi"
            width="20"
            height="20"
          ></img>
        );
      } else {
        return (
          <img
            alt=""
            src="./icons/icons8-no-network-32.png"
            className="i-eth"
            width="20"
            height="20"
          ></img>
        );
      }
    default:
      return (
        <img
          alt=""
          src="./icons/icons8-no-network-32.png"
          className="i-eth"
          width="20"
          height="20"
        ></img>
      );
  }
}

export function getBatteryIcon(batteryOutput) {
  if (batteryOutput.state === 'full') {
    return (
      <img alt="" src="./icons/icons8-battery-max-charged-32.png" width="20" height="20"></img>
    );
  } else if (batteryOutput.state === 'charging') {
    return <img alt="" src="./icons/icons8-battery-charging-32.png" width="20" height="20"></img>;
  } else if (batteryOutput.state === 'discharging') {
    if (batteryOutput.chargePercent > 90)
      return <img alt="" src="./icons/icons8-battery-4-32.png" width="20" height="20"></img>;
    if (batteryOutput.chargePercent > 70)
      return <img alt="" src="./icons/icons8-battery-3-32.png" width="20" height="20"></img>;
    if (batteryOutput.chargePercent > 45)
      return <img alt="" src="./icons/icons8-battery-2-32.png" width="20" height="20"></img>;
    if (batteryOutput.chargePercent > 15)
      return <img alt="" src="./icons/icons8-battery-1-32.png" width="20" height="20"></img>;
    return <img alt="" src="./icons/icons8-battery-32.png" width="20" height="20"></img>;
  }
}

export function getBatteryUsageRate(batteryOutput) {
  if (batteryOutput.chargePercent > 70) return 'low-usage';
  if (batteryOutput.chargePercent > 45) return 'medium-usage';
  if (batteryOutput.chargePercent > 15) return 'high-usage';
  return 'extreme-usage';
}

export function getWeatherIcon(weatherOutput) {
  switch (weatherOutput.status) {
    case 'clear_day':
      return <i className="nf nf-weather-day_sunny"></i>;
    case 'clear_night':
      return <i className="nf nf-weather-night_clear"></i>;
    case 'cloudy_day':
      return <i className="nf nf-weather-day_cloudy"></i>;
    case 'cloudy_night':
      return <i className="nf nf-weather-night_alt_cloudy"></i>;
    case 'light_rain_day':
      return <i className="nf nf-weather-day_sprinkle"></i>;
    case 'light_rain_night':
      return <i className="nf nf-weather-night_alt_sprinkle"></i>;
    case 'heavy_rain_day':
      return <i className="nf nf-weather-day_rain"></i>;
    case 'heavy_rain_night':
      return <i className="nf nf-weather-night_alt_rain"></i>;
    case 'snow_day':
      return <i className="nf nf-weather-day_snow"></i>;
    case 'snow_night':
      return <i className="nf nf-weather-night_alt_snow"></i>;
    case 'thunder_day':
      return <i className="nf nf-weather-day_lightning"></i>;
    case 'thunder_night':
      return <i className="nf nf-weather-night_alt_lightning"></i>;
  }
}

export function getAppIcon(appName) {
  switch (appName) {
    case 'brave':
      return <img alt="" src="./icons/icons8-brave-32.png" className="app-icon"></img>;
    case 'Discord':
      return <img alt="" src="./icons/icons8-discord-new-32.png" className="app-icon"></img>;
    case 'explorer':
      return <img alt="" src="./icons/icons8-file-explorer-new-32.png" className="app-icon"></img>;
    case 'WindowsTerminal':
      return <img alt="" src="./icons/icons8-terminal-32.png" className="app-icon"></img>;
    case 'Code':
      return (
        <img
          alt=""
          src="./icons/icons8-visual-studio-code-insides-32.png"
          className="app-icon"
        ></img>
      );
    case 'devenv':
      return <img alt="" src="./icons/icons8-visual-studio-32.png" className="app-icon"></img>;
    case 'ApplicationFrameHost':
      return <img alt="" src="./icons/icons8-settings-32.png" className="app-icon"></img>;
    case 'Spotify':
      return <img alt="" src="./icons/icons8-spotify-32.png" className="app-icon"></img>;
    case 'msedgewebview2':
      return <img alt="" src="./icons/icons8-edge-32.png" className="app-icon"></img>;
    case 'steamwebhelper':
      return <img alt="" src="./icons/icons8-steam-32.png" className="app-icon"></img>;
    case 'Messenger':
      return <img alt="" src="./icons/icons8-facebook-messenger-32.png" className="app-icon"></img>;
    case 'SystemInformer':
      return <img alt="" src="./icons/systeminformer-32x32.png" className="app-icon"></img>;
    case 'MediBangPaintPro':
      return <img alt="" src="./icons/icons8-medibang-paint-32.png" className="app-icon"></img>;
    case 'Docker Desktop':
      return <img alt="" src="./icons/icons8-docker-32.png" className="app-icon"></img>;
    case 'obs64':
      return <img alt="" src="./icons/icons8-obs-32.png" className="app-icon"></img>;
    case 'sublime_text':
      return <img alt="" src="./icons/icons8-sublime-text-32.png" className="app-icon"></img>;
    case 'FanSpeedSetting':
      return <img alt="" src="./icons/icons8-fan-32.png" className="app-icon"></img>;
    case '7zFM':
      return <img alt="" src="./icons/icons8-7zip-32.png" className="app-icon"></img>;
    default:
      return <img alt="" src="./icons/icons8-application-32.png" className="app-icon"></img>;
  }
}

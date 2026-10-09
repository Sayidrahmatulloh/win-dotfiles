import { runCommand } from './src/actions';
import React, { useState, useEffect } from "react";
import { createRoot } from "react-dom/client";
import * as zebar from "zebar";

const providers = zebar.createProviderGroup({
  glazewm: { type: "glazewm" },
  cpu: { type: "cpu", refreshInterval: 2000 },
  memory: { type: "memory", refreshInterval: 4000 },
  weather: { type: "weather" },
  network: { type: "network", refreshInterval: 2000 },
  battery: { type: "battery", refreshInterval: 10000 },
  date: { type: "date", formatting: "HH:mm" },
});

createRoot(document.getElementById("root")).render(<App />);

function App() {
  const [actionError,setActionError] = useState('');
  useEffect(() => { const listener = event => setActionError(event.detail); window.addEventListener('widget-action-error',listener); return () => window.removeEventListener('widget-action-error',listener); }, []);
  const [output, setOutput] = useState(providers.outputMap);

  useEffect(() => {
    let active = true;
    providers.onOutput(() => { if (active) setOutput(providers.outputMap); });
    return () => { active = false; void providers.stopAll().catch(console.error); };
  }, []);

  // Change the color of the CPU bar based on usage.
  function getCpuUsageRate(cpuOutput) {
    if (cpuOutput.usage > 90) return "extreme-usage";
    else if (cpuOutput.usage > 65) return "high-usage";
    else if (cpuOutput.usage > 30) return "medium-usage";
    else return "low-usage";
  }

  // Change the color of the memory bar based on usage.
  function getMemoryUsageRate(memoryOutput) {
    if (memoryOutput.usage > 90) return "extreme-usage";
    else if (memoryOutput.usage > 65) return "high-usage";
    else if (memoryOutput.usage > 45) return "medium-usage";
    else return "low-usage";
  }

  // Get icon to show for current network status.
  function getNetworkIcon(networkOutput) {
    switch (networkOutput.defaultInterface?.type) {
      case "ethernet":
        return (
          <img alt=""
            src="./icons/icons8-wired-network-32.png"
            className="i-eth"
            width="20"
            height="20"
          ></img>
        );
      case "wifi":
        if (networkOutput.defaultGateway?.signalStrength >= 75) {
          return (
            <img alt=""
              src="./icons/icons8-wifi-3-32.png"
              className="i-wifi"
              width="20"
              height="20"
            ></img>
          );
        } else if (networkOutput.defaultGateway?.signalStrength >= 45) {
          return (
            <img alt=""
              src="./icons/icons8-wifi-2-32.png"
              className="i-wifi"
              width="20"
              height="20"
            ></img>
          );
        } else if (networkOutput.defaultGateway?.signalStrength >= 5) {
          return (
            <img alt=""
              src="./icons/icons8-wifi-1-32.png"
              className="i-wifi"
              width="20"
              height="20"
            ></img>
          );
        } else {
          return (
            <img alt=""
              src="./icons/icons8-no-network-32.png"
              className="i-eth"
              width="20"
              height="20"
            ></img>
          );
        }
      default:
        return (
          <img alt=""
            src="./icons/icons8-no-network-32.png"
            className="i-eth"
            width="20"
            height="20"
          ></img>
        );
    }
  }

  // Get icon to show for how much of the battery is charged.
  function getBatteryIcon(batteryOutput) {
    if (batteryOutput.state === "full") {
      return (
        <img alt=""
          src="./icons/icons8-battery-max-charged-32.png"
          width="20"
          height="20"
        ></img>
      );
    } else if (batteryOutput.state === "charging") {
      return (
        <img alt=""
          src="./icons/icons8-battery-charging-32.png"
          width="20"
          height="20"
        ></img>
      );
    } else if (batteryOutput.state === "discharging") {
      if (batteryOutput.chargePercent > 90)
        return (
          <img alt=""
            src="./icons/icons8-battery-4-32.png"
            width="20"
            height="20"
          ></img>
        );
      if (batteryOutput.chargePercent > 70)
        return (
          <img alt=""
            src="./icons/icons8-battery-3-32.png"
            width="20"
            height="20"
          ></img>
        );
      if (batteryOutput.chargePercent > 45)
        return (
          <img alt=""
            src="./icons/icons8-battery-2-32.png"
            width="20"
            height="20"
          ></img>
        );
      if (batteryOutput.chargePercent > 15)
        return (
          <img alt=""
            src="./icons/icons8-battery-1-32.png"
            width="20"
            height="20"
          ></img>
        );
      return (
        <img alt="" src="./icons/icons8-battery-32.png" width="20" height="20"></img>
      );
    }
  }

  // Change the color of the battery bar based on how much of the battery is charged.
  function getBatteryUsageRate(batteryOutput) {
    if (batteryOutput.chargePercent > 70) return "low-usage";
    if (batteryOutput.chargePercent > 45) return "medium-usage";
    if (batteryOutput.chargePercent > 15) return "high-usage";
    return "extreme-usage";
  }

  // Get icon to show for current weather status.
  function getWeatherIcon(weatherOutput) {
    switch (weatherOutput.status) {
      case "clear_day":
        return <i className="nf nf-weather-day_sunny"></i>;
      case "clear_night":
        return <i className="nf nf-weather-night_clear"></i>;
      case "cloudy_day":
        return <i className="nf nf-weather-day_cloudy"></i>;
      case "cloudy_night":
        return <i className="nf nf-weather-night_alt_cloudy"></i>;
      case "light_rain_day":
        return <i className="nf nf-weather-day_sprinkle"></i>;
      case "light_rain_night":
        return <i className="nf nf-weather-night_alt_sprinkle"></i>;
      case "heavy_rain_day":
        return <i className="nf nf-weather-day_rain"></i>;
      case "heavy_rain_night":
        return <i className="nf nf-weather-night_alt_rain"></i>;
      case "snow_day":
        return <i className="nf nf-weather-day_snow"></i>;
      case "snow_night":
        return <i className="nf nf-weather-night_alt_snow"></i>;
      case "thunder_day":
        return <i className="nf nf-weather-day_lightning"></i>;
      case "thunder_night":
        return <i className="nf nf-weather-night_alt_lightning"></i>;
    }
  }
  function getAppIcon(appName) {
    switch (appName) {
      case "brave":
        return (
          <img alt="" src="./icons/icons8-brave-32.png" className="app-icon"></img>
        );
      case "Discord":
        return (
          <img alt=""
            src="./icons/icons8-discord-new-32.png"
            className="app-icon"
          ></img>
        );
      case "explorer":
        return (
          <img alt=""
            src="./icons/icons8-file-explorer-new-32.png"
            className="app-icon"
          ></img>
        );
      case "WindowsTerminal":
        return (
          <img alt="" src="./icons/icons8-terminal-32.png" className="app-icon"></img>
        );
      case "Code":
        return (
          <img alt=""
            src="./icons/icons8-visual-studio-code-insides-32.png"
            className="app-icon"
          ></img>
        );
      case "devenv":
        return (
          <img alt=""
            src="./icons/icons8-visual-studio-32.png"
            className="app-icon"
          ></img>
        );
      case "ApplicationFrameHost":
        return (
          <img alt="" src="./icons/icons8-settings-32.png" className="app-icon"></img>
        );
      case "Spotify":
        return (
          <img alt="" src="./icons/icons8-spotify-32.png" className="app-icon"></img>
        );
      case "msedgewebview2":
        return (
          <img alt="" src="./icons/icons8-edge-32.png" className="app-icon"></img>
        );
      case "steamwebhelper":
        return (
          <img alt="" src="./icons/icons8-steam-32.png" className="app-icon"></img>
        );
      case "Messenger":
        return (
          <img alt=""
            src="./icons/icons8-facebook-messenger-32.png"
            className="app-icon"
          ></img>
        );
      case "SystemInformer":
        return (
          <img alt=""
            src="./icons/systeminformer-32x32.png"
            className="app-icon"
          ></img>
        );
      case "MediBangPaintPro":
        return (
          <img alt=""
            src="./icons/icons8-medibang-paint-32.png"
            className="app-icon"
          ></img>
        );
      case "Docker Desktop":
        return (
          <img alt="" src="./icons/icons8-docker-32.png" className="app-icon"></img>
        );
      case "obs64":
        return <img alt="" src="./icons/icons8-obs-32.png" className="app-icon"></img>;
      case "sublime_text":
        return (
          <img alt=""
            src="./icons/icons8-sublime-text-32.png"
            className="app-icon"
          ></img>
        );
      case "FanSpeedSetting":
        return <img alt="" src="./icons/icons8-fan-32.png" className="app-icon"></img>;
      case "7zFM":
        return (
          <img alt="" src="./icons/icons8-7zip-32.png" className="app-icon"></img>
        );
      default:
        return (
          <img alt=""
            src="./icons/icons8-application-32.png"
            className="app-icon"
          ></img>
        );
    }
  }
  function renderChilds(child, index) {
    if (child.type === "window") {
      return (
        <button className={`element ${child.hasFocus ? "focus" : ""}`}
        key={child.id} title={child.title} aria-label={"Focus " + child.title}
        onClick={() => {
          runCommand(output.glazewm, `shell-exec '%userprofile%/.glzr/zebar/attaquer-buildless/scripts/FocusWindow.ahk' ${child.handle}`);
        }}
        >
          {getAppIcon(child.processName)}
        </button>
      );
    } else if (child.type === "split") {
      return (
        <div className="template" key={child.id}>
          {child.children.map((subChild, subIndex) =>
            renderChilds(subChild, subIndex)
          )}
        </div>
      );
    }
    return null;
  }

  return (
    <div className="app">{actionError && <button type="button" role="status" title={actionError} aria-label={actionError + " Click to dismiss."} onClick={() => setActionError("")} style={{position:"fixed",right:0,top:0,zIndex:10,background:"#462323",color:"white"}}>!</button>}
      <div className="left">
        <button
          type="button" aria-label="Start menu" className="logo"
          onClick={() => {
            runCommand(output.glazewm, 
              "shell-exec '%userprofile%/.glzr/zebar/attaquer-buildless/scripts/OpenStartMenu.vbs'"
            );
          }}
        >
          <span className="content"></span>
        </button>
        <button
          type="button" aria-label="Windows search" className="search"
          onClick={() => {
            runCommand(output.glazewm, 
              "shell-exec '%userprofile%/.glzr/zebar/attaquer-buildless/scripts/OpenWindowsSearch.ahk'"
            );
          }}
        >
          <span className="content">
            <img alt=""
              src="./icons/icons8-search-32.png"
              width="19"
              height="19"
            ></img>
          </span>
        </button>
        {output.glazewm && (
          <>
            <div className="workspaces">
              {output.glazewm.currentWorkspaces.map((workspace) => (
                <button
                  className={`workspace ${workspace.hasFocus && "focused"} ${
                    workspace.isDisplayed && "displayed"
                  }`}
                  onClick={() =>
                    runCommand(output.glazewm, 
                      `focus --workspace ${workspace.name}`
                    )
                  }
                  key={workspace.name}
                  id={workspace.name}
                >
                  <span className="workspace-icon">
                    {workspace.name === "web" ? (
                      <img
                        src="./icons/icons8-brave-web-browser-32.png"
                        alt="5"
                        className="i-brave"
                        height="16"
                        width="16"
                      ></img>
                    ) : (
                      workspace.displayName ?? workspace.name
                    )}
                  </span>
                </button>
              ))}
            </div>
            <div className="template">
              <button
                aria-label="Toggle tiling direction" className={`toggle-tiling-direction ${
                  output.glazewm.tilingDirection === "horizontal"
                    ? "horizontal"
                    : "vertical"
                }`}
                onClick={() =>
                  runCommand(output.glazewm, "toggle-tiling-direction")
                }
              >
                <span className="tiling-direction"></span>
              </button>
            </div>
            <div className="template">
              {output.glazewm.bindingModes.map((bindingMode) => (
                <span className="binding-mode">
                  {bindingMode.displayName ?? bindingMode.name}
                </span>
              ))}
            </div>
          </>
        )}
      </div>

      <div className="center">
        {/* {output.glazewm && (
          <>
          {output.glazewm.focusedWorkspace.children.map(
            (window) =>
            window.hasFocus && (
              <div className="current-window" key={window.id}>
                {window.title && (
                  window.title?.length > 90
                  ? window.title.slice(0, 90) + '...'
                  : window.title
                )}
              </div>
              )
            )}
          </>
        )} */}
        {output.glazewm &&
          output.glazewm.currentWorkspaces.map(
            (workspace) =>
              workspace.isDisplayed && (
                <div className="template" key={workspace.name}>
                  {workspace.children.map((child, index) =>
                    renderChilds(child, index)
                  )}
                </div>
              )
          )}
      </div>

      <div className="right">
        {output.glazewm?.allWindows.filter(window => window.processName.toLowerCase() === 'spotify').map(window => <div className="template spotify" key={window.id} title={window.title}><img src="./icons/icons8-spotify-32.png" width="18" height="18" alt=""/>{window.title}</div>)}
        {output.cpu && (
          <button
            aria-label="Open Task Manager: CPU" className={`cpu ${getCpuUsageRate(output.cpu)}`}
            onClick={() => {
              runCommand(output.glazewm, 
                "shell-exec taskmgr"
              );
            }}
          >
            <span className="content">
              <span className="i-cpu"></span>
              <span className="cpu-bar">{Math.round(output.cpu.usage)}%</span>
            </span>
          </button>
        )}
        {output.memory && (
          <button
            aria-label="Open Task Manager: memory" className={`memory ${getMemoryUsageRate(output.memory)}`}
            onClick={() => {
              runCommand(output.glazewm, 
                "shell-exec taskmgr"
              );
            }}
          >
            <span className="content">
              <span className="i"></span>
              <div className="labels">
                <span className="label total">
                  <span>USED</span>
                  {Math.round(output.memory.usedMemory / 1024 / 1024 / 1024)}G
                </span>
                <span className="label total">
                  <span>TOT</span>
                  {Math.round(output.memory.totalMemory / 1024 / 1024 / 1024)}G
                </span>
              </div>
              <span className="mem-bar">
                {" "}
                {Math.round(output.memory.usage)}%
              </span>
            </span>
          </button>
        )}
        {output.weather && (
          <div className="template weather">
            {getWeatherIcon(output.weather)}
            {Math.round(output.weather.celsiusTemp)}°C
          </div>
        )}
        {output.network && (
          <button
            type="button" aria-label="Network quick settings" className="network"
            onClick={() => {
              runCommand(output.glazewm, 
                "shell-exec '%userprofile%/.glzr/zebar/attaquer-buildless/scripts/OpenActionCenter.ahk'"
              );
            }}
          >
            <span className="content">
              {getNetworkIcon(output.network)}
              <div className="labels">
                <span className="label">
                  <span className="ii"></span>
                  <span className="net-line">
                    {output.network.traffic?.received.siValue ?? '—'}{" "}
                    {output.network.traffic?.received.siUnit}
                  </span>
                </span>
                <span className="label">
                  <span className="ii"></span>
                  <span className="net-line">
                    {output.network.traffic?.transmitted.siValue ?? '—'}{" "}
                    {output.network.traffic?.transmitted.siUnit}
                  </span>
                </span>
              </div>
            </span>
          </button>
        )}

        {output.battery && (
          <div
            className={`template battery ${getBatteryUsageRate(
              output.battery
            )}`}
          >
            {getBatteryIcon(output.battery)}
            {Math.round(output.battery.chargePercent)}%
          </div>
        )}

        {output.date && (
          <button
            type="button" aria-label="Notification center" className="date"
            onClick={() => {
              runCommand(output.glazewm, 
                "shell-exec explorer.exe ms-actioncenter://"
              );
            }}
          >
            <span className="content">
              <img alt=""
                src="./icons/icons8-time-32.png"
                className="i-time"
                width="17"
                height="17"
              ></img>
              <span className="time">{output.date?.formatted}</span>
            </span>
          </button>
        )}
      </div>
    </div>
  );
}

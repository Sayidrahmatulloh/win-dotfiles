import React, {useEffect,useState} from 'react';
import {createRoot} from 'react-dom/client';
import * as zebar from 'zebar';
import {safeAction} from './utils';
import Icon from './components/Icon';
import SpotifyWidget from './components/SpotifyWidget';
import GoogleSearch from './components/GoogleSearch';
import Settings, {loadPreference} from './components/Settings';
import Shortcut from './components/Shortcut';
import ActiveApp from './components/ActiveApp';
import defaults from './config.defaults';
const config = {...defaults,...Object.values(import.meta.glob('./config.js',{eager:true,import:'default'}))[0]};
const preview = new URLSearchParams(location.search).has('preview');
const mock = {
 host:{hostname:'VELVET'}, date:{now:'2026-10-09T10:42:00'},
 cpu:{usage:12}, memory:{usage:38}, battery:{chargePercent:86,isCharging:false}, weather:{status:'clear_day',celsiusTemp:24},
 glazewm:{currentWorkspaces:[1,2,3,4,5].map(name => ({name:String(name),hasFocus:name === 2,isDisplayed:name === 2})),allWindows:[{hasFocus:true,title:'Quiet Velvet · Design',processName:'Code'}],bindingModes:[],tilingDirection:'horizontal',runCommand:async()=>{}},
 media:{currentSession:{title:'Weightless',artist:'Marconi Union',isPlaying:true},previous:async()=>{},next:async()=>{},togglePlayPause:async()=>{}}
};
const providers = preview ? null : zebar.createProviderGroup({media:{type:'media'},glazewm:{type:'glazewm'},cpu:{type:'cpu'},date:{type:'date',formatting:'HH:mm'},battery:{type:'battery'},memory:{type:'memory'},weather:{type:'weather'},host:{type:'host'}});
function App() {
 const [output,setOutput] = useState(preview ? mock : providers.outputMap);
 const [actionError,setActionError] = useState('');
 const [media,setMedia] = useState(() => loadPreference('Media'));
 const [search,setSearch] = useState(() => loadPreference('Google'));
 const [shortcuts,setShortcuts] = useState(() => loadPreference('Shortcuts'));
 const [activeApp,setActiveApp] = useState(() => loadPreference('App'));
 useEffect(() => {
  if (!providers) return;
  let active = true;
  providers.onOutput(() => { if (active) setOutput({...providers.outputMap}); });
  return () => { active = false; void providers.stopAll().catch(console.error); };
 },[]);
 useEffect(() => { const listener = event => setActionError(event.detail); window.addEventListener('widget-action-error',listener); return () => window.removeEventListener('widget-action-error',listener); },[]);
 const date = output.date?.now ? new Date(output.date.now) : null;
 const wm = output.glazewm;
 const taskManager = () => safeAction(() => preview ? Promise.resolve() : zebar.shellExec('taskmgr'));
 const percentage = value => Number.isFinite(value) ? Math.round(value) + '%' : '—';
 return <main className="app" aria-label="Quiet Velvet desktop bar">
  <section className="left" aria-label="Workspaces and apps">
   <div className="box workspace-box">
    <div className="identity" title={output.host?.hostname || 'Quiet Velvet'}><Icon name="windows" className="accent"/><span>{output.host?.hostname || 'Velvet'}</span></div>
    <nav className="workspaces" aria-label="Workspaces">{wm?.currentWorkspaces.map(workspace => <button type="button" key={workspace.name} className={`workspace ${workspace.hasFocus ? 'focused' : workspace.isDisplayed ? 'displayed' : ''}`} aria-label={`Workspace ${workspace.displayName ?? workspace.name}`} aria-pressed={workspace.hasFocus} onClick={() => safeAction(() => wm.runCommand(`focus --workspace "${workspace.name}"`))}>{workspace.displayName ?? workspace.name}</button>)}</nav>
    {shortcuts && wm && <div className="shortcuts"><Shortcut commandRunner={wm.runCommand} commands={[`shell-exec "${config.edgePath}"`]} icon="globe" name="Browser"/><Shortcut commandRunner={wm.runCommand} commands={[`shell-exec "${config.powershellPath}" -nologo`]} icon="terminal" name="PowerShell"/></div>}
   </div>
   {activeApp && <ActiveApp output={output}/>}
  </section>
  <section className="center" aria-label="Clock"><div className="box clock" title={date?.toLocaleDateString('en-GB',{weekday:'long',day:'numeric',month:'long',year:'numeric'})}><span className="clock-time">{date?.toLocaleTimeString('en-GB',{hour:'2-digit',minute:'2-digit'}) ?? '—'}</span><span className="clock-date">{date?.toLocaleDateString('en-GB',{weekday:'short',day:'2-digit',month:'short'}) ?? 'Waiting for clock'}</span></div></section>
  <section className="right" aria-label="Media and system status">
   {media && <div className="box media-box"><SpotifyWidget media={output.media}/></div>}
   {search && <GoogleSearch preview={preview}/>}
   <div className="box system-box">
    {wm?.bindingModes.map(mode => <span className="binding-mode" key={mode.name}>{mode.displayName ?? mode.name}</span>)}
    {wm && <button type="button" className="icon-button tiling" title="Toggle tiling direction" aria-label="Toggle tiling direction" onClick={() => safeAction(() => wm.runCommand('toggle-tiling-direction'))}><Icon name={wm.tilingDirection === 'horizontal' ? 'horizontal' : 'vertical'}/></button>}
    <Settings widgetObj={[{name:'Media',value:media,changeState:setMedia},{name:'Google',value:search,changeState:setSearch},{name:'Shortcuts',value:shortcuts,changeState:setShortcuts},{name:'App',value:activeApp,changeState:setActiveApp}]} additionalContent={<div className="status-items">
     {output.cpu && <button className={`metric ${output.cpu.usage > 85 ? 'high-usage' : ''}`} title="CPU usage · Open Task Manager" aria-label={`CPU ${percentage(output.cpu.usage)}. Open Task Manager`} onClick={taskManager}><Icon name="cpu"/><span>{percentage(output.cpu.usage)}</span></button>}
     {output.memory && <button className="metric memory" title="Memory usage · Open Task Manager" aria-label={`Memory ${percentage(output.memory.usage)}. Open Task Manager`} onClick={taskManager}><Icon name="memory"/><span>{percentage(output.memory.usage)}</span></button>}
     {output.battery && <span className={`metric battery ${output.battery.chargePercent < 20 ? 'high-usage' : ''}`} title={output.battery.isCharging ? 'Battery charging' : 'Battery'}><Icon name="battery"/><span>{percentage(output.battery.chargePercent)}{output.battery.isCharging ? '+' : ''}</span></span>}
     {output.weather && <span className="metric weather" title={output.weather.status?.replaceAll('_',' ')}><Icon name={output.weather.status?.startsWith('clear') ? 'sun' : 'cloud'}/><span>{Number.isFinite(output.weather.celsiusTemp) ? Math.round(output.weather.celsiusTemp) + '°' : '—'}</span></span>}
    </div>}/>
   </div>
  </section>
  {actionError && <button type="button" className="action-error" role="status" title={actionError} aria-label={actionError + ' Click to dismiss.'} onClick={() => setActionError('')}><Icon name="warning"/>Command failed<Icon name="close"/></button>}
 </main>;
}
createRoot(document.getElementById('root')).render(<App/>);

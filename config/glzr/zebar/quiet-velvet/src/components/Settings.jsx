import React, {useEffect,useState} from 'react';
function load(name) { try { return localStorage.getItem(name) !== 'false'; } catch { return true; } }
export default function Settings({widgetObj,additionalContent}) {
 const [open,setOpen] = useState(false);
 const [states,setStates] = useState(() => Object.fromEntries(widgetObj.map(w => [w.name,load(w.name)])));
 useEffect(() => { widgetObj.forEach(w => w.changeState(states[w.name])); }, [states]);
 function toggle(name,value) { setStates(current => ({...current,[name]:value})); try {localStorage.setItem(name,String(value));}catch(error){console.error('Preferences could not be saved',error);} }
 return <div className="logo settings-group"><button type="button" aria-label="Widget settings" aria-expanded={open} className="nf nf-cod-settings_gear settings clean-button" onClick={() => setOpen(!open)}/>{open ? <div className="widget-settings">{widgetObj.map(w => <label key={w.name}><input type="checkbox" checked={states[w.name] ?? true} onChange={e => toggle(w.name,e.target.checked)}/>{w.name}</label>)}</div> : additionalContent}</div>;
}

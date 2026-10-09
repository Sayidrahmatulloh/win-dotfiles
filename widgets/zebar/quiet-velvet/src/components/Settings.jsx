import React, {useState} from 'react';
import Icon from './Icon';
export function loadPreference(name) { try { return localStorage.getItem(name) !== 'false'; } catch { return true; } }
export default function Settings({widgetObj,additionalContent}) {
 const [open,setOpen] = useState(false);
 return <div className="settings-group" onKeyDown={event => { if (event.key === 'Escape') { setOpen(false); event.currentTarget.querySelector('button').focus(); } }}>
  {open ? <div className="widget-settings" id="widget-preferences" role="group" aria-label="Visible widgets">{widgetObj.map(widget => <label key={widget.name}><input type="checkbox" checked={widget.value} onChange={event => { widget.changeState(event.target.checked); try {localStorage.setItem(widget.name,String(event.target.checked));}catch(error){console.error(error);} }}/><span>{widget.name}</span></label>)}</div> : additionalContent}
  <button type="button" title={open ? 'Close settings' : 'Widget settings'} aria-label={open ? 'Close settings' : 'Widget settings'} aria-expanded={open} aria-controls={open ? 'widget-preferences' : undefined} className={`icon-button settings ${open ? 'selected' : ''}`} onClick={() => setOpen(!open)}><Icon name={open ? 'close' : 'settings'}/></button>
 </div>;
}

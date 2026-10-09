import React, {useState} from 'react';
import {shellExec} from 'zebar';
import {searchUrl} from '../utils';
import Icon from './Icon';
export default function GoogleSearch({preview = false}) {
 const [query,setQuery] = useState(''), [error,setError] = useState(''), [busy,setBusy] = useState(false);
 async function submit(event) {
  event.preventDefault(); if (!query.trim() || busy) return; setBusy(true);
  try { if (!preview) await shellExec('explorer.exe',[searchUrl(query)]); setQuery(''); setError(''); }
  catch(error) { console.error(error); setError('Search could not open'); }
  finally { setBusy(false); }
 }
 return <form className="search box" onSubmit={submit} title={error || 'Search Google'}>
  <Icon name="search"/>
  <input aria-label="Search Google" placeholder="Search" value={query} onChange={event => setQuery(event.target.value)}/>
  <button className="icon-button search-submit" type="submit" disabled={busy || !query.trim()} aria-label="Submit search"><Icon name="horizontal"/></button>
  {error && <span className="search-error" role="status">{error}</span>}
 </form>;
}

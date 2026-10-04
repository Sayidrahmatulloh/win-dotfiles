import React, {useState} from 'react';
import {shellExec} from 'zebar';
import {searchUrl} from '../utils';
export default function GoogleSearch() {
 const [query,setQuery] = useState(''), [error,setError] = useState(''), [busy,setBusy] = useState(false);
 async function submit(event) {
  event.preventDefault(); if (!query.trim() || busy) return; setBusy(true);
  try { await shellExec('explorer.exe', [searchUrl(query)]); setQuery(''); setError(''); }
  catch(error) { console.error(error); setError('Search could not open'); }
  finally { setBusy(false); }
 }
 return <form className="logo box" onSubmit={submit}>
  <input aria-label="Search Google" placeholder="Search on Google" value={query} onChange={e => setQuery(e.target.value)}/>
  <button className="clean-button" type="submit" disabled={busy} aria-label="Submit search">⌕</button>
  {error && <span role="status">{error}</span>}
 </form>;
}

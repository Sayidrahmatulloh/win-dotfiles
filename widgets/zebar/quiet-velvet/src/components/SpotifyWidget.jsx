import React, {useState} from 'react';
import Icon from './Icon';
import {mediaAction, safeAction} from '../utils';
export default function SpotifyWidget({media}) {
 const session = media?.currentSession;
 const [busy,setBusy] = useState(false);
 if (!session) return null;
 async function run(action) { setBusy(true); try { await safeAction(() => mediaAction(media,action)); } finally { setBusy(false); } }
 return <div className="media-widget" title={[session.title,session.artist].filter(Boolean).join(' — ')}>
  <Icon name="music" className="accent"/>
  <div className="media-copy"><span className="media-title">{session.title || 'Media'}</span><span className="media-artist">{session.artist || 'Now playing'}</span></div>
  <div className="media-controls">
   {[['previous','Previous track','previous'],['togglePlayPause',session.isPlaying ? 'Pause' : 'Play',session.isPlaying ? 'pause' : 'play'],['next','Next track','next']].map(([action,label,icon]) => <button key={action} type="button" className="icon-button" aria-label={label} disabled={busy} onClick={() => run(action)}><Icon name={icon}/></button>)}
  </div>
 </div>;
}

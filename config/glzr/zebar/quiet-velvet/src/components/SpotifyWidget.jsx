import React from 'react';
import { mediaAction, safeAction } from '../utils';
// File name retained for existing imports; this supports every Windows media session.
export default function SpotifyWidget({media}) {
 const session = media?.currentSession;
 if (!session) return null;
 return <div className="media-widget" title={[session.title,session.artist].filter(Boolean).join(' — ')}>
  <span className="media-title">{session.title || 'Media'}{session.artist ? ' — ' + session.artist : ''}</span>
  <button type="button" className="clean-button" aria-label="Previous track" onClick={() => safeAction(() => mediaAction(media,'previous'))}>⏮</button>
  <button type="button" className="clean-button" aria-label={session.isPlaying ? 'Pause' : 'Play'} onClick={() => safeAction(() => mediaAction(media,'togglePlayPause'))}>{session.isPlaying ? '⏸' : '▶'}</button>
  <button type="button" className="clean-button" aria-label="Next track" onClick={() => safeAction(() => mediaAction(media,'next'))}>⏭</button>
 </div>;
}

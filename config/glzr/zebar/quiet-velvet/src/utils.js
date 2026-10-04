export async function mediaAction(media, action) {
 if (!media || !['previous','togglePlayPause','next'].includes(action)) return;
 await media[action]();
}
export function searchUrl(text) {
 const url = new URL('https://www.google.com/search');
 url.searchParams.set('q', text.trim());
 return url.href;
}
export async function safeAction(action) {
 try { await action(); }
 catch (error) { console.error('Widget action failed', error); window.dispatchEvent(new CustomEvent('widget-action-error', {detail:'Command failed. Check Zebar logs.'})); }
}

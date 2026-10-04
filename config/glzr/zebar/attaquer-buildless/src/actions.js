export async function runCommand(wm, command) {
 try { if (!wm) throw new Error('GlazeWM unavailable'); await wm.runCommand(command); }
 catch(error) { console.error('Command failed', error); window.dispatchEvent(new CustomEvent('widget-action-error', {detail:'Command failed. Check Zebar logs.'})); }
}

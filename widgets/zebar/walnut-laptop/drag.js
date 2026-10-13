// Slide the screen to either side; a grip remains available to pull it back.
const laptop = document.querySelector('.laptop');
const grip = document.createElement('button');
grip.type = 'button';
grip.className = 'side-grip';
grip.hidden = true;
grip.setAttribute('aria-label', 'Laptopni qayta chiqarish');
grip.textContent = '‹';
document.body.append(grip);
let side = 0;
let drag;
let moved = false;

function limit() {
  // Move beyond the monitor edge, not just beyond the former widget bounds.
  return (innerWidth + laptop.getBoundingClientRect().width) / 2 + 30;
}
function paint(offset) { laptop.style.translate = `${offset}px 0`; }
function settle(nextSide) {
  side = nextSide;
  paint(side * limit());
  grip.hidden = side === 0;
  grip.style.left = side < 0 ? '8px' : 'auto';
  grip.style.right = side > 0 ? '8px' : 'auto';
  grip.textContent = side > 0 ? '‹' : '›';
}
function begin(event) {
  if (event.button !== 0) return;
  event.preventDefault();
  moved = false;
  drag = { id: event.pointerId, x: event.clientX, side, offset: side * limit() };
  event.currentTarget.setPointerCapture(event.pointerId);
  document.body.classList.add('dragging');
}
laptop.addEventListener('pointerdown', begin);
grip.addEventListener('pointerdown', begin);
window.addEventListener('pointermove', event => {
  if (!drag || event.pointerId !== drag.id) return;
  const delta = event.clientX - drag.x;
  if (Math.abs(delta) > 4) moved = true;
  paint(Math.max(-limit(), Math.min(limit(), drag.offset + delta)));
});
window.addEventListener('pointerup', event => {
  if (!drag || event.pointerId !== drag.id) return;
  const delta = event.clientX - drag.x;
  const previous = drag.side;
  drag = undefined;
  document.body.classList.remove('dragging');
  if (Math.abs(delta) < 24) settle(previous);
  else if (previous) settle(delta * previous < 0 ? 0 : previous);
  else settle(delta > 0 ? 1 : -1);
});
window.addEventListener('pointercancel', () => {
  drag = undefined;
  document.body.classList.remove('dragging');
  settle(side);
});
grip.addEventListener('click', () => {
  if (moved) { moved = false; return; }
  settle(0);
});
window.addEventListener('resize', () => settle(side));
let lockRevision = 0;
let checkingLock = false;
setInterval(async () => {
  if (checkingLock) return;
  checkingLock = true;
  try {
    const response = await fetch('./lock-state.json', { cache: 'no-store' });
    if (!response.ok) return;
    const state = await response.json();
    if (state.revision > lockRevision && !drag) {
      lockRevision = state.revision;
      settle(state.hidden ? 1 : 0);
    }
  } catch { /* The laptop remains usable without the companion app. */ }
  finally { checkingLock = false; }
}, 500);

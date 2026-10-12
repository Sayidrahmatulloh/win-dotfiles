// Drag the handle vertically; keep it visible when the keyboard is folded away.
export function setupKeyboardDrag() {
  const keyboard = document.querySelector('.keyboard');
  const handle = document.createElement('button');
  handle.type = 'button';
  handle.className = 'keyboard-handle';
  handle.setAttribute('aria-label', 'Klaviaturani yuqoriga tortib chiqarish');
  handle.hidden = true;
  handle.setAttribute('aria-expanded', 'true');
  document.body.append(handle);

  let offset = 0;
  let maximum = 0;
  let baseTop = 0;
  let folded = false;
  let drag;
  let dragged = false;

  function render(value) {
    offset = Math.max(0, Math.min(maximum, value));
    document.documentElement.style.setProperty('--keyboard-offset', `${offset}px`);
    handle.style.top = `${baseTop + offset}px`;
  }

  function resize() {
    const rect = keyboard.getBoundingClientRect();
    baseTop = Math.max(8, rect.top - offset - 56);
    maximum = Math.max(0, innerHeight - 48 - baseTop);
    render(folded ? maximum : offset);
  }

  function settle(collapse) {
    folded = collapse;
    handle.hidden = !folded;
    render(folded ? maximum : 0);
    handle.setAttribute('aria-expanded', String(!folded));
  }

  function beginDrag(event) {
    if (event.button !== 0) return;
    if (event.target.closest('.key')) return;
    event.preventDefault();
    dragged = false;
    drag = { id: event.pointerId, y: event.clientY, offset, folded };
    event.currentTarget.setPointerCapture(event.pointerId);
    document.body.classList.add('keyboard-dragging');
  }
  handle.addEventListener('pointerdown', beginDrag);
  keyboard.addEventListener('pointerdown', beginDrag);
  window.addEventListener('pointermove', event => {
    if (!drag || event.pointerId !== drag.id) return;
    const delta = event.clientY - drag.y;
    if (Math.abs(delta) > 4) dragged = true;
    render(drag.offset + delta);
  });
  function finish(event) {
    if (!drag || event.pointerId !== drag.id) return;
    const moved = dragged;
    const delta = event.clientY - drag.y;
    const wasFolded = drag.folded;
    drag = undefined;
    document.body.classList.remove('keyboard-dragging');
    if (moved) settle(Math.abs(delta) >= 24 ? delta > 0 : wasFolded);
  }
  window.addEventListener('pointerup', finish);
  window.addEventListener('pointercancel', event => {
    if (!drag || event.pointerId !== drag.id) return;
    drag = undefined;
    document.body.classList.remove('keyboard-dragging');
    settle(folded);
  });
  handle.addEventListener('click', () => {
    if (dragged) { dragged = false; return; }
    settle(!folded);
  });
  handle.addEventListener('keydown', event => {
    if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
      event.preventDefault();
      settle(event.key === 'ArrowDown');
    }
  });
  return { resize };
}

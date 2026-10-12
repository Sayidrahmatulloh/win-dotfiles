import { shellExec } from './zebar.js';
import { setupKeyboardDrag } from './drag.js';

const keyboardDrag = setupKeyboardDrag();

const ui = Object.fromEntries(
  ['keys', 'editor', 'editTitle', 'url', 'error', 'selected', 'description', 'sound', 'loadError']
    .map(id => [id, document.getElementById(id)])
);
const storageKey = 'walnut.links';
let customLinks = readSavedLinks();
let editingKey;
let audio;
let soundEnabled = false;
let browserProgram;

function readSavedLinks() {
  try {
    const value = JSON.parse(localStorage.getItem(storageKey) || '{}');
    return value && typeof value === 'object' && !Array.isArray(value) ? value : {};
  } catch {
    return {};
  }
}

function webUrl(value) {
  const url = new URL(value);
  if (!['https:', 'http:'].includes(url.protocol)) throw new Error('Faqat HTTP/HTTPS havolalari mumkin.');
  return url.href;
}

function showStatus(key) {
  ui.selected.textContent = key.name;
  ui.description.textContent = key.program || customLinks[key.name] || key.url || 'Klaviatura boshqaruv tugmasi';
}

function showError(message) {
  ui.loadError.textContent = message;
  ui.loadError.hidden = false;
}

function playClick() {
  if (!soundEnabled) return;
  try {
    audio ??= new AudioContext();
    void audio.resume();
    const oscillator = audio.createOscillator();
    const gain = audio.createGain();
    oscillator.type = 'triangle';
    oscillator.frequency.setValueAtTime(230, audio.currentTime);
    oscillator.frequency.exponentialRampToValueAtTime(80, audio.currentTime + 0.04);
    gain.gain.setValueAtTime(0.045, audio.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, audio.currentTime + 0.055);
    oscillator.connect(gain);
    gain.connect(audio.destination);
    oscillator.start();
    oscillator.stop(audio.currentTime + 0.06);
  } catch (error) {
    console.warn('Ovoz ijro etilmadi:', error);
  }
}

function toggleSound() {
  soundEnabled = !soundEnabled;
  ui.sound.textContent = `Sound · ${soundEnabled ? 'on' : 'off'}`;
  ui.sound.setAttribute('aria-pressed', String(soundEnabled));
  playClick();
}

function editLink(key) {
  if (!key.url) return;
  editingKey = key;
  ui.editTitle.textContent = `${key.name} · manzil`;
  ui.url.value = customLinks[key.name] || key.url;
  ui.error.hidden = true;
  ui.editor.showModal();
}

async function activateKey(key) {
  playClick();
  showStatus(key);
  ui.loadError.hidden = true;
  if (key.program) {
    try {
      const result = await shellExec(key.program, []);
      if (result.code !== 0) throw new Error(result.stderr || 'Dastur ishga tushmadi.');
    } catch (error) {
      console.error(error);
      showError(`${key.name}: dasturni ochib bo‘lmadi.`);
    }
  } else if (key.url) {
    try {
      const result = await shellExec(browserProgram, [webUrl(customLinks[key.name] || key.url)]);
      if (result.code !== 0) throw new Error(result.stderr || 'Brauzer ishga tushmadi.');
    } catch (error) {
      console.error(error);
      showError(`${key.name}: havolani ochib bo‘lmadi.`);
    }
  } else if (key.action === 'sound') {
    toggleSound();
  } else if (key.action === 'reset') {
    ui.selected.textContent = 'YOUR TOOLS. AT YOUR FINGERTIPS.';
    ui.description.textContent = 'Tugmani bosing · Manzilni o‘zgartirish uchun o‘ng tugma yoki uzoq bosish';
  }
}

function image(path, className = '') {
  const element = document.createElement('img');
  element.src = path;
  element.alt = '';
  element.className = className;
  element.draggable = false;
  return element;
}

function createKey(key) {
  const button = document.createElement('button');
  button.type = 'button';
  button.className = `key${key.icon ? '' : ' mod'}${key.icon === 'space' ? ' space' : ''}`;
  button.style.setProperty('--size', key.size || 1);
  button.style.setProperty('--logo', key.color || '#eadcc4');
  button.setAttribute('aria-label', key.name + (key.url ? ' — havolani ochish' : ''));
  if (key.icon === 'space') {
    button.append(image('./assets/space-art.svg', 'art'), image('./assets/space-shield.svg', 'space-logo'));
  } else if (key.icon) {
    const icon = document.createElement('span');
    icon.className = 'key-icon';
    icon.setAttribute('aria-hidden', 'true');
    icon.style.setProperty('--icon-image', `url("./assets/icons/${key.icon}.svg")`);
    button.append(icon);
  }
  const label = document.createElement('span');
  label.className = 'label';
  label.textContent = key.name;
  if (key.icon !== 'space') button.append(label);

  let holdTimer;
  let longPress = false;
  button.addEventListener('pointerdown', event => {
    if (event.button !== 0) return;
    longPress = false;
    holdTimer = setTimeout(() => {
      if (key.url) { longPress = true; editLink(key); }
    }, 650);
  });
  for (const event of ['pointerup', 'pointerleave', 'pointercancel']) {
    button.addEventListener(event, () => clearTimeout(holdTimer));
  }
  button.addEventListener('click', () => {
    if (longPress) { longPress = false; return; }
    void activateKey(key);
  });
  button.addEventListener('contextmenu', event => { event.preventDefault(); editLink(key); });
  button.addEventListener('keydown', event => {
    if (event.shiftKey && event.key === 'F10') { event.preventDefault(); editLink(key); }
  });
  button.addEventListener('mouseenter', () => showStatus(key));
  button.addEventListener('focus', () => showStatus(key));
  return button;
}

// The logical keyboard size stays stable; scale it to fit both viewport axes.
function fitKeyboard() {
  const keyboard = document.querySelector('.keyboard');
  const scale = Math.min(1, (innerWidth - 64) / 1100, (innerHeight - 90) / (keyboard.offsetHeight + 50));
  document.documentElement.style.setProperty('--keyboard-scale', String(Math.max(0.05, scale)));
  keyboardDrag.resize();
}

function validateConfiguration(config) {
  if (!config.browser || typeof config.browser.program !== 'string' || !config.browser.program.trim()) {
    throw new Error('browser.program brauzer yo‘li ko‘rsatilmagan.');
  }
  if (!Array.isArray(config.rows) || !config.rows.length) throw new Error('rows ro‘yxati topilmadi.');
  for (const row of config.rows) {
    if (!Array.isArray(row) || !row.length) throw new Error('Tugmalar qatori bo‘sh.');
    for (const key of row) {
      if (!key || typeof key.name !== 'string' || !key.name.trim()) throw new Error('Tugma nomi noto‘g‘ri.');
      if (key.url) webUrl(key.url);
      if (key.icon && !/^[a-z0-9_-]+$/.test(key.icon)) throw new Error('Ikonka nomi noto‘g‘ri.');
      if (key.size !== undefined && (!Number.isFinite(key.size) || key.size <= 0)) throw new Error('Tugma kengligi noto‘g‘ri.');
    }
  }
  const tilt = config.tiltDegrees ?? 30;
  if (!Number.isFinite(tilt) || tilt < 0 || tilt > 60) throw new Error('Qiyalik 0–60° oralig‘ida bo‘lishi kerak.');
  return tilt;
}

async function loadKeyboard() {
  try {
    const response = await fetch('./keyboard.json', { cache: 'no-store' });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const config = await response.json();
    const tilt = validateConfiguration(config);
    browserProgram = config.browser.program;
    document.documentElement.style.setProperty('--keyboard-tilt', `${tilt}deg`);
    for (const keys of config.rows) {
      const row = document.createElement('div');
      row.className = 'row';
      row.append(...keys.map(createKey));
      ui.keys.append(row);
    }
    // Finish measuring before showing the keyboard at its final scale.
    await document.fonts.ready;
    await Promise.all([...ui.keys.querySelectorAll('img')].map(image => image.decode().catch(() => {})));
    await new Promise(requestAnimationFrame);
    fitKeyboard();
    document.body.classList.add('keyboard-ready');
  } catch (error) {
    console.error(error);
    showError(`keyboard.json yuklanmadi: ${error.message}`);
  }
}

ui.sound.addEventListener('click', toggleSound);
document.getElementById('theme').addEventListener('click', event => {
  const light = document.body.classList.toggle('light');
  event.currentTarget.textContent = light ? 'Dark' : 'Light';
  event.currentTarget.setAttribute('aria-pressed', String(light));
});
document.getElementById('widget').addEventListener('click', () => document.body.classList.add('widget'));
document.getElementById('cancel').addEventListener('click', () => ui.editor.close());
document.getElementById('exit').addEventListener('click', () => ui.editor.close());
document.addEventListener('keydown', event => { if (event.key === 'Escape') ui.editor.close(); });
document.getElementById('editForm').addEventListener('submit', event => {
  event.preventDefault();
  let url;
  try { url = webUrl(ui.url.value); } catch { ui.error.hidden = false; return; }
  const nextLinks = { ...customLinks, [editingKey.name]: url };
  try {
    localStorage.setItem(storageKey, JSON.stringify(nextLinks));
  } catch {
    showError('Havolani saqlab bo‘lmadi.');
    return;
  }
  customLinks = nextLinks;
  ui.editor.close();
  showStatus(editingKey);
});
window.addEventListener('resize', fitKeyboard);
void loadKeyboard();

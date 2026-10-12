import { shellExec } from './zebar.js';

const errorMessage = document.getElementById('error');
const symbols = {
  browser: '<svg viewBox="0 0 32 32" fill="none"><circle cx="16" cy="16" r="12" stroke="#73b3d0" stroke-width="2"/><ellipse cx="16" cy="16" rx="5" ry="12" stroke="#73b3d0" stroke-width="2"/><path d="M4 16h24M7 9h18M7 23h18" stroke="#73b3d0"/></svg>',
  folder: '<svg viewBox="0 0 32 32"><path d="M3 7h10l3 4h13v16H3z" fill="#c39a58"/><path d="M3 13h26v14H3z" fill="#e3bd78"/></svg>',
};

function updateClock() {
  const now = new Date();
  document.getElementById('time').textContent = new Intl.DateTimeFormat('uz-UZ', { hour: '2-digit', minute: '2-digit', hour12: false }).format(now);
  document.getElementById('date').textContent = new Intl.DateTimeFormat('uz-UZ', { weekday: 'long', day: 'numeric', month: 'long' }).format(now);
  const hour = now.getHours();
  document.getElementById('greeting').textContent = hour < 6 ? 'Tungi sokinlik' : hour < 12 ? 'Xayrli tong' : hour < 18 ? 'Xayrli kun' : 'Xayrli kech';
}

async function loadApps() {
  try {
    const response = await fetch('./laptop.json', { cache: 'no-store' });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const config = await response.json();
    for (const app of config.apps) {
      const button = document.createElement('button');
      button.className = 'app';
      button.type = 'button';
      if (app.icon === 'vscode') {
        const image = document.createElement('img');
        image.src = './assets/space-shield.svg';
        image.alt = '';
        button.append(image);
      } else {
        const icon = document.createElement('span');
        icon.setAttribute('aria-hidden', 'true');
        icon.innerHTML = symbols[app.icon] || symbols.folder;
        button.append(icon);
      }
      const label = document.createElement('span');
      label.textContent = app.name;
      button.append(label);
      button.addEventListener('click', async () => {
        errorMessage.hidden = true;
        try {
          const result = await shellExec(app.program, app.args || []);
          if (result.code !== 0) throw new Error(result.stderr);
        } catch (error) {
          console.error(error);
          errorMessage.textContent = `${app.name} ochilmadi.`;
          errorMessage.hidden = false;
        }
      });
      document.getElementById('apps').append(button);
    }
  } catch (error) {
    errorMessage.textContent = 'Laptop sozlamalarini yuklab bo‘lmadi.';
    errorMessage.hidden = false;
    console.error(error);
  }
}
updateClock();
setInterval(updateClock, 1000);
void loadApps();

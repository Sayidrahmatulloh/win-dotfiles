# Walnut keyboard

Build talab qilinmaydi. Zebar `index.html`ni ochadi; `main.js` ma’lumotni `keyboard.json`dan yuklaydi.

- `index.html` — sahifa va tahrirlash oynasi.
- `styles.css` — yog‘och ko‘rinishi, perspektiva, oynaga mos masshtab.
- `main.js` — JSON yuklash, tugmalar, havolalar, ovoz va tahrirlash.
- `keyboard.json` — qatorlar va tugmalar ma’lumoti.
- `assets/` — mahalliy SVG ikonkalari.
- `zebar.js` — Zebar API kutubxonasi; qo‘lda tahrirlanmaydi.
- `zpack.json` — Zebar joylashuvi va ruxsatlari.

JSON tugma namunasi:

```json
{
  "name": "Python",
  "icon": "python",
  "color": "#3679a8",
  "url": "https://python.org",
  "size": 1
}
```

`rows` ichidagi har bir massiv — bitta qator. `size` — qator ichidagi nisbiy kenglik. `icon` — `assets/icons/` ichidagi SVG fayl nomi, kengaytmasiz. `space` maxsus bezakli tugma. Ikonkasiz tugmalar uchun `action`: `sound`, `reset` yoki `none`.

`tiltDegrees: 30` — X o‘qi bo‘yicha 30° perspektiv qiyalik. 0–60° oralig‘i qo‘llanadi.

JSON o‘zgargach Zebar widgetini qayta yuklang. O‘ng tugma bilan saqlangan manzillar `localStorage`da turadi va JSONdagi standart havoladan ustun keladi. Faqat HTTP/HTTPS havolalari ochiladi.
Havolalar `browser.program`da ko‘rsatilgan brauzer orqali bevosita ochiladi (hozir Chrome). Brauzerni almashtirganda `zpack.json` ichidagi `privileges.shellCommands` program yo‘lini ham moslang va Zebarni qayta ishga tushiring.

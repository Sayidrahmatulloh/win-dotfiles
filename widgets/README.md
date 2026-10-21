# Zebar widgetlari

Widget manba kodi va runtime sozlamalari alohida saqlanadi:

- `zebar/attaquer-solid-ts/` — asosiy SolidJS/TypeScript paneli.
- `zebar/attaquer-buildless/` — alohida qo'shimcha variant.
- `zebar/walnut-keyboard/`, `zebar/walnut-laptop/` — mustaqil widget paketlari.
- `zebar/normalize.css` — runtime uchun umumiy stylesheet.

Faol build `../setup.json`dagi `zebar.widget` bilan tanlanadi. Startup sozlamalari
`../config/glzr/zebar/settings.json`da. Paketlarning ichki yo'llari runtime linklari
bilan bog'liq, shu sabab nomini o'zgartirganda manifest, link va startup'ni birga tekshiring.

Har bir build qilinadigan widget o'z dependency va lockfile'iga egalik qiladi.
Komponent testlari ham widgetning o'z `tests/` papkasida qoladi. `dist/`,
`node_modules/` va vendor runtime nusxalari authored kod hisoblanmaydi.

[Asosiy panel arxitekturasi](zebar/attaquer-solid-ts/README.md).

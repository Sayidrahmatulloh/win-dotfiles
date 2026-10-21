# Attaquer Solid

`setup.json` tanlagan asosiy Zebar paneli. SolidJS interfeysni, Zebar providerlari
Windows va GlazeWM ma'lumotlarini beradi.

Repo papkasidan:

```powershell
bun test --cwd widgets/zebar/attaquer-solid-ts
bun run --cwd widgets/zebar/attaquer-solid-ts typecheck
bun run --cwd widgets/zebar/attaquer-solid-ts build
```

`build` dependency'larni lockfile orqali tekshiradi, shriftni tayyorlaydi va
natijani vaqtinchalik katalogda yig'adi. Desktop assetlar tekshirilgach yangi
`dist` yoqiladi, avvalgi build backup sifatida saqlanadi. `dev` fayllarni kuzatib
to'g'ridan-to'g'ri build qiladi; oddiy production yangilash uchun `build` ishlatiladi.

## Kod joylashuvi

```text
src/
  index.tsx              Brauzer kirish nuqtasi
  App.tsx                Panel qismlarini joylashtirish
  components/            Har bir panel qismi: TSX va yonidagi CSS
    Media/               Media boshqaruvi va marquee lifecycle
    Tooltip/             Tooltip komponenti va uslubi
    ThemeSwitcher/       Theme katalogini ko'rsatish
  services/
    desktop/             GlazeWM/Windows amallari va executable topish
    providers/           Zebar provider state, retry, xato va cleanup
    runtime/             Widget brauzer hodisalari
  hooks/                 Umumiy UI hook'lari
  shared/                UI va desktop API'dan mustaqil format funksiyalari
  styles/                Rang tokenlari, animatsiyalar, ikonlar va compact layout
  fonts/                 Build uchun shrift assetlari
```

`App.tsx` xizmatlardan ma'lumot olib komponentlarga uzatadi. Komponentlar xizmatlar
va oddiy helperlardan foydalanishi mumkin. `services/` komponentlarni import
qilmaydi; `shared/` esa komponent va xizmatlardan mustaqil qoladi. `tests/architecture.test.ts`
shu bog'lanishlar va modul yo'llarini tekshiradi.

- `services/providers/useProviders.ts` — provider ma'lumotlari, retry va cleanup.
- `services/providers/health.ts` — xatolarni ko'rsatish qoidalari.
- `services/desktop/actions.ts` — Solid state va Zebar desktop API adapteri.
- `services/desktop/widgetActions.ts` — desktop amallarining testlanadigan modeli.
- `tooling/desktop-assets.mjs` — theme va desktop assetlarini build'ga yig'ish.

Desktop va ma'lumot manbalarini amalda ishlatish uchun Zebar kerak. Testlar
desktop buyruqlarini bajarmaydi. Butun repo tekshiruvi: `tools/check.ps1`.

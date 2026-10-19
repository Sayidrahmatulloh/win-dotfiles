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

- `src/index.tsx` — sahifani ishga tushirish va umumiy CSS importlari.
- `src/App.tsx` — panel qismlarini joylashtirish.
- `src/hooks/useProviders.ts` — provider ma'lumotlari, xatolar, retry va cleanup.
- `src/providerHealth.ts` — xatoni ko'rsatish qoidalari.
- `src/actions.ts`, `src/widgetActions.ts` — desktop amallari va executable topish.
- `src/Media/` — media boshqaruvi va matn animatsiyasi.
- `src/styles/` — tokenlar, animatsiyalar va icon fontlari.
- `src/compact.css` — ixcham panel va umumiy interaction uslublari.
- `tests/` — desktop action va provider lifecycle regression testlari.
- `tooling/desktop-assets.mjs` — umumiy theme assetlarini build'ga yig'ish.

Desktop va ma'lumot manbalarini amalda ishlatish uchun Zebar kerak. Testlar
desktop buyruqlarini bajarmaydi. Butun repo tekshiruvi: `tools/check.ps1`.

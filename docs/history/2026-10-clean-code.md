# Clean Code asosida bosqichma-bosqich refaktor

## Maqsad va joriy holat

Loyihadagi kodni o'qish, tekshirish va o'zgartirishni osonlashtirish.
Har bir bosqich aniq bir qismni yaxshilaydi va o'z tekshiruvi bilan yakunlanadi.
Funksiyalar, hotkeylar, o'rnatish tartibi va dizayn refaktor davomida saqlanadi.

- **Tayyor:** Neovim konfiguratsiyasi `standalone`, `vscode_nvim`, `shared`
  qismlariga ajratilgan; ranglar markazlashtirilgan, UI vazifalari ajratilgan.
  Muhitlar, sidebar/inputlar, HTTP, formatlash, ignore va PowerShell tekshirilgan.
- **Tayyor:** butun loyiha bo'yicha dastlabki tuzilma auditi va ushbu reja.
- **Tayyor:** barcha 10 bosqich bajarildi; boshlang'ich va yakuniy tekshiruv
  natijalari ushbu hujjatda qayd etilgan.

Repo ichidagi avvalgi o'zgarishlar saqlanadi. Har bosqich boshlanishida mavjud
o'zgarishlar qayd etiladi, yangi refaktorning chegarasi aniqlanadi.

## Ishlash tartibi

Har bir bosqich shu ketma-ketlikda bajariladi:

1. Tegishli kod, chaqiruvchilar va mavjud testlarni o'qish.
2. Kuzatilgan muammoni aniq yozish: takror, yashirin bog'liqlik, aralash vazifa
   yoki tushunarsiz xato boshqaruvi.
3. Eng kichik foydali o'zgarishni qilish; nomlarni ma'noli va uslubni izchil saqlash.
4. Tegishli tekshiruvlarni bajarish; muhim xatti-harakat uchun zarur regression
   testi yetishmasa, uni qo'shish.
5. Natijani ko'rib chiqish, hujjat va ushbu rejaning holatini yangilash.

Bir bosqichdagi yangi xato bartaraf etilgach keyingisiga o'tiladi.
Oldindan mavjud xatolar alohida qayd etiladi. Fayl uzunligi va qatorlar soni
yordamchi belgi; asosiy mezon vazifa va bog'liqliklarning tushunarliligi.

## Bosqichlar

| # | Qism | Aniq ish | Yakunlash mezoni | Holat |
| --- | --- | --- | --- | --- |
| 1 | Audit va boshlang'ich tekshiruv | Mavjud testlar, build va hozirgi xatolarni qayd etish; refaktor chegaralarini belgilash | Boshlang'ich natijalar va test buyruqlari hujjatlashtirilgan | Tayyor |
| 2 | Umumiy PowerShell kutubxonalari | `lib/` ichida ma'lumot o'qish, buyruq bajarish, natija va hisobot vazifalarini tekshirish | Chaqiruvchilar bilan mos interfeyslar, tegishli kutubxona testlari o'tgan | Tayyor |
| 3 | Bootstrap va installer | `bootstrap.ps1`, `install.ps1`, `scripts/install/` oqimi va bosqich bog'liqliklarini soddalashtirish | Birinchi o'rnatish, qayta ishga tushirish, `-Only`/`-Skip` xatti-harakati saqlangan | Tayyor |
| 4 | Linklar, backup va runtime build | `scripts/install/links.ps1`, `lib/core/files.ps1`, `lib/setup.ps1`, build vositalaridagi vazifalarni ajratish | Muvaffaqiyat va xatodan tiklanish testlari o'tgan; eski konfiguratsiya saqlanadi | Tayyor |
| 5 | PowerShell profili va dastur sozlamalari | Profil yuklash, modullar, prompt, aliaslar va yordamchi buyruqlarni tartiblash; Terminal/Git/GlazeWM sozlamalarini tekshirish | Profil, terminal, aliaslar va mos konfiguratsiya testlari o'tgan | Tayyor |
| 6 | Theme tizimi | `themes/`, `scripts/theme/` va ularning iste'molchilaridagi takroriy qoidalarni tekshirish | Theme katalogi bilan CLI va widget tanlovi mos; ranglar va tiklash ishlaydi | Tayyor |
| 7 | Faol Zebar widgeti | `attaquer-solid-ts` ichida providerlar, amallar, komponentlar va resurslarni tozalashni ajratish | TypeScript, widget action testlari va production build o'tgan | Tayyor |
| 8 | CSS va qolgan widget variantlari | Takroriy uslublar, komponent nomlari, layout qoidalari va variantlar bog'liqligini tartiblash | Har bir tegilgan variant o'z tekshiruvidan o'tgan; ko'rinish solishtirilgan | Tayyor |
| 9 | Yordamchi dasturlar | `tools/`, jumladan `walnut-lock` PowerShell/C# va Neovim repair vositalarini tekshirish | Tegilgan vositalarning xatti-harakati tekshirilgan; launcherlar mos | Tayyor |
| 10 | Yakuniy tekshiruv va hujjatlar | CI, test ishga tushirish, README va arxitektura hujjatlarini yakunlash | Umumiy testlar va build natijasi boshlang'ich holat bilan solishtirilgan | Tayyor |

## 1-bosqich: boshlang'ich holat

2026-10-19: boshlang'ich 19 ta PowerShell test to'plami, 4 ta widget testi,
TypeScript, production build va desktop asset tekshiruvi o'tdi. Neovimning
7 ta tuzilma/integratsiya holati ham o'tdi. Boshlang'ich nosoz test kuzatilmadi.

- Git'dagi mavjud o'zgarishlarni qayd etish.
- `tests/run.ps1` orqali PowerShell testlarini alohida jarayonlarda bajarish.
- Faol widget yo'lini `setup.json`dan olish va o'sha widgetning testlarini ishlatish.
- TypeScript tekshiruvi, production build va desktop asset mosligini tekshirish.
- Neovim bo'yicha mavjud yettita tekshiruvni umumiy natijaga kiritish.
- Mavjud xatolarni refaktor davomida paydo bo'lgan xatolardan ajratib yozish.

Boshlang'ich buyruqlar:

```powershell
pwsh -NoProfile -File ./tests/run.ps1
. ./lib/setup/settings.ps1
$widgetPath = (Get-SetupConfig -RepoRoot $PWD.Path).zebar.widget
bun test --cwd $widgetPath
bun run --cwd $widgetPath typecheck
bun run --cwd $widgetPath build
pwsh -NoProfile -File ./tools/check-desktop-build.ps1
```

Build tanlangan widgetning dependency va shriftlari tayyorligini talab qiladi.
Yetishmayotgan talab boshlang'ich hisobotda qayd etiladi. Kod refaktoridan
oldin tekshiruv muhitining ishlashi aniqlanadi.

## Dastlabki audit qaydlari (refaktordan oldingi holat)

### Kutubxonalar va installer

`lib/setup/settings.ps1` konfiguratsiyani tekshiradi, `lib/core/commands.ps1` tashqi
buyruqlarni bajaradi, `lib/core/results.ps1` natijalarni yig'adi. Shu chegaralar
saqlanadi. `lib/setup.ps1` hozir modul o'rnatish va Zebar build/runtime
amallarini birlashtiradi; ajratish zarurati chaqiruvchilar bilan birga baholanadi.
`lib/diagnostics.ps1`dagi alohida tekshiruvlar va umumiy hisobot oqimi ham ko'riladi.

Bootstrap yangi kompyuterda repo hali yo'q bo'lgan holatda ishlaydi va
Windows PowerShell 5.1 bilan mos bo'lishi kerak. Umumlashtirish shu talabni
saqlashi kerak. Qayta ishga tushirish mavjud paket va sozlamalarni to'g'ri tanisin.

### Profil va theme

`user_profile.ps1` modul yuklash, PSReadLine/FZF, aliaslar, kompilyatsiya
yordamchilari va texnik xizmat buyruqlarini o'z ichiga oladi. Ular yuklanish
tartibi va foydalanuvchi buyruqlarini saqlagan holda ko'rib chiqiladi.
Scoop modul yo'llari va PowerShell versiyalari bilan bog'liq tuzatishlar tekshiriladi.

Theme ID, wallpaper va cursor qoidalarining asosiy manbasi `themes/themes.json`.
Neovimning `shared/colors.lua` fayli bilan boshqa dasturlar orasidagi takrorlar
iste'molchilarning haqiqiy yuklash imkoniyatiga qarab baholanadi.

### Zebar va yordamchi dasturlar

Faol widget `setup.json`dagi `zebar.widget` bilan belgilanadi. Avval uning
`index.tsx`, `actions.ts`, media va tooltip qismlarida vazifalar, holat,
xatolar, timer va event listener hayot sikli tekshiriladi. Asosli takrorlar
umumlashtiriladi; faqat bitta joyda kerak bo'lgan kod joyida qolishi mumkin.

CSS refaktorida ko'rinish, hover/focus, tooltip, ixcham rejim va ekran
o'lchamlari solishtiriladi. Qolgan Zebar variantlari o'z ishlatish usuliga
qarab tekshiriladi; faol widgetning build mezoni ularga avtomatik qo'llanmaydi.

`walnut-lock`da oyna, klaviatura hodisalari, holat va resurslarni bo'shatish
vazifalari tekshiriladi. Build/runtime launcher yo'llari birga ko'rib chiqiladi.

## Har bosqich yakunidagi hisobot

- Qaysi muammo yaxshilandi va qaysi fayllar o'zgardi.
- Qanday xatti-harakatlar tekshirildi.
- O'tgan, bajarilmagan va oldindan mavjud nosoz tekshiruvlar.
- Keyingi bosqichning aniq vazifasi.

Kod va ma'lumot fayllari ushbu rejaning doirasida. Dependency kataloglari,
generatsiya qilingan build natijalari va binar assetlar manba kodi sifatida
refaktor qilinmaydi. Hujjatlar va konfiguratsiya yo'llari o'zgarishlarga mos yangilanadi.

## Bajarilgan ishlar — 2026-10-19

1. Boshlang'ich natijalar va avvalgi Git o'zgarishlari tekshirildi.
2. Konfiguratsiyani o'qish va tekshirish ajratildi. Paket siklidagi ichma-ich
   shartlar kamaytirildi, natijalarni birlashtirish parametrlari aniq nomlandi.
3. Installer'da tanlangan bosqichlar ma'lumotini tekshirish va bosqichlarni
   bajarish alohida funksiyalarga ajratildi. Repo yo'q holatdagi bootstrap
   mustaqilligi va Windows PowerShell 5.1 argument uzatishi saqlandi.
4. Modullar `lib/setup/modules.ps1`, Zebar build va runtime `lib/zebar/`ga ajratildi.
   Directory backup va link yaratish qoidalari umumlashtirildi; rollback
   holatlari mavjud testlar bilan tekshirildi.
5. PowerShell profili to'rtta vazifaga ajratildi. Modul importidagi xato
   haqiqiy sababini bildiradi. Terminal/Git/GlazeWM konfiguratsiyalari
   ko'rib chiqildi; ularning ma'lumot formatlari saqlandi.
6. GlazeWM matnini o'zgartirish va reload `GlazeConfig.ps1`ga ajratildi.
   CRLF/LF, takroriy qo'llash va noaniq YAML uchun testlar qo'shildi.
   Desktop build theme yordamchi fayllarini ro'yxat orqali avtomatik oladi.
7. Faol widgetda kirish nuqtasi, App, provider lifecycle va media animatsiyasi
   ajratildi. Batareya retry chegarasi, tiklanish va timer cleanup testlari bor.
8. CSS tokenlari, animatsiya va icon fontlari ajratildi; keyingi qoidalar
   allaqachon almashtirgan rang deklaratsiyalari olib tashlandi. JS/TS/CSS
   uslubi izchil qilindi. Buildless'da
   status helperlari ajratildi. Walnut widgetlari va ularning alohida runtime
   bog'liqliklari ko'rib chiqildi; vendor kutubxonalari o'zgartirilmadi.
9. Walnut credential va UI funksiyalari ajratildi; credential yo'li aniq
   parametr bo'ldi. Ikki ekran uchun takroriy overlay yaratish umumlashtirildi.
   C# hook va launcherlar mosligi self-test bilan tekshirildi. Repair/build
   yordamchilarining chegaralari ko'rib chiqildi.
10. `tools/check.ps1` va `tools/check-nvim.ps1` qo'shildi. CI konfiguratsiyasi
    buildless widget va pluginsiz Neovim tuzilmasini tekshiradi. CI font
    yordamchisi boshqa widget font papkasini ham qabul qiladi; tarmoqsiz
    regression testi bor. README va arxitektura yo'riqnomalari yangilandi.

### Yakuniy tekshiruvlar

- PowerShell: 22 test to'plami; 67 ta manba faylining sintaksisi ham tekshiriladi.
- Widget: 9 test, TypeScript va faol widgetning production build'i.
- Qo'shimcha variant: `attaquer-buildless` build'i.
- Neovim: 2 ta muhit tuzilmasi va 5 ta amaliy integratsiya tekshiruvi.
- CSS: namunaviy panelda 1920/1100/900/650/500 px kengliklarda normal,
  hover, focus va purple theme holatlari — 20 ta CSSOM va pixel solishtiruvi.
- Tegilgan JS/TS/CSS uchun Prettier tekshiruvi va Git whitespace tekshiruvi.

Mahalliy tekshiruvlar o'tdi. GitHub Actions'ning yangi joblari konfiguratsiyaga
qo'shildi; remote CI hali ishga tushirilmagan. Yangi Windows kompyuterida haqiqiy
installer, ishlayotgan GlazeWM IPC, ekran lockini faol yoqish va barcha desktop
widget hodisalarining to'liq sinovi ushbu regression natijalariga kirmaydi.

Qayta tekshirish:

```powershell
./tools/check.ps1 -Neovim -Variants
```

## Tuzilmani aniqlashtirish — 2026-10-21

- PowerShell helperlari `lib/core/` va `lib/setup/`ga guruhlandi; public loaderlar saqlandi.
- Link/profil o'rnatish `scripts/install/links.ps1`ga o'tdi; eski buyruq compatibility entry sifatida qoladi.
- Neovim entry point, feature, platform, keymap va UI vazifalari ajratildi.
- Asosiy Zebar widgetida `components/`, `services/`, `shared/` chegaralari ajratildi.
- PowerShell importlari, Neovim qatlamlari va widget bog'lanishlari uchun regression tekshiruvlari qo'shildi.
- README xaritalari va CONTRIBUTING qo'llanmasi yangi yo'llarga moslashtirildi.

Tekshiruv: 23 ta PowerShell suite, 10 ta widget testi, TypeScript va production build,
desktop asset tekshiruvi, ikkala Neovim muhiti va o'rnatilgan integratsiya sinovlari o'tdi.
Windows bloklagan CSS/JSON parserlari uchun umumiy zaxira yo'li qo'shildi va sinovdan o'tdi.
Prettier qo'llandi. StyLua executable'ini Windows Application Control bloklagani uchun
avtomatik Lua formatlash bajarilmadi; Lua sintaksisi va importlari tekshirildi.

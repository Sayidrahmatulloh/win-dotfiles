# Loyiha arxitekturasi

Root'dagi uchta skript foydalanuvchi kirish nuqtalari: `bootstrap.ps1`
PowerShell 7'ni tayyorlaydi, `install.ps1` o'rnatish bosqichlarini bajaradi,
`doctor.ps1` esa o'zgartirmasdan tekshiradi.

## Papkalar vazifasi

| Papka | Nima saqlanadi |
| --- | --- |
| `widgets/zebar/` | Zebar dastur kodi, testlar, dependency va build vositalari |
| `config/` | Dasturlarning o'z formatidagi konfiguratsiyalar |
| `scripts/install/` | Paket, shrift va cursor o'rnatish bosqichlari |
| `scripts/theme/` | Windows ko'rinishini o'zgartiradigan umumiy PowerShell kodi |
| `assets/` | ZIP va rasm kabi manba fayllar, tegishli litsenziyalar |
| `themes/` | Mavzularning yagona JSON katalogi |
| `lib/` | Setup va doctor foydalanadigan umumiy funksiyalar |
| `tools/` | CI tayyorgarligi va build tekshiruvlari |
| `tests/` | Vaqtinchalik fixture'lar bilan regression testlar |
| `docs/` | Tuzilma, ishlatish va kengaytirish yo'riqnomalari |

Runtime ma'lumotlari repo ichiga yozilmaydi: log va cursor backup'lari
`%LOCALAPPDATA%\win-dotfiles` ichida, Zebar build'i esa Git'dan chiqarilgan
`dist/` ichida saqlanadi. GlazeWM sozlamalari symlink orqali faol ishlaydi,
shu sababli border rangini almashtirish repo config'ida ham ko'rinadi.

## O'rnatish oqimi

`bootstrap.ps1` → `install.ps1` → manifest va theme tekshiruvi → Scoop →
Winget → fonts → cursors → PowerShell modullari → symlinklar → Git →
Terminal → Zebar build.

Yangi bosqich `scripts/install/` ichiga qo'shiladi va root installer'dan
`Invoke-Step` orqali chaqiriladi. Bosqich muvaffaqiyatsiz tugasa exception
qaytaradi; root installer log va yakuniy natijani chiqaradi.

## Mavzu va asset oqimi

`themes/themes.json` har bir mavzuning ID, label, accent, surface, wallpaper
va cursor katalogini belgilaydi. Zebar shu JSON'ni import qiladi; PowerShell
ham xuddi shu faylni o'qiydi.

`assets/cursors/Bibata-Modern-Zebar.zip` cursor'lar uchun asosiy tarqatiladigan
manba. Ochilgan `.cur` va `.ani` fayllari repo'da takroran saqlanmaydi.
Cursor ranglari o'zgartirilmaydi: green → Amber, blue → Ice, purple → Classic.
O'rnatish ZIP'ni foydalanuvchi papkasiga ochadi, avvalgi cursor sxemasini
saqlaydi va tanlangan Bibata rangini qo'llaydi. Qayta o'rnatish fayllarni tiklaydi.

Zebar'ning Vite plagini markaziy skriptlar, JSON, cursor ZIP va faqat
katalogdagi wallpaper'larni `dist/desktop/` ichiga nusxalaydi. Natijada
repo va build bir xil nisbiy tuzilmani ishlatadi. Build nusxalarini qo'lda
tahrirlash kerak emas. Zebar shell ruxsati faqat `ApplyTheme.ps1` va ruxsat
etilgan mavzu argumentlariga berilgan; yangi ID qo'shilganda `zpack.json`
ruxsati ham yangilanadi va `tests/themes.ps1` bilan tekshiriladi.

## Neovim va Zebar variantlari

`config/nvim/init.lua` oddiy Neovim uchun `lua/config` va `lua/plugins`,
VS Code uchun esa `lua/vs/config` va `lua/vs/plugins`ni tanlaydi. Bu ikki
muhitning vazifalari farq qiladi; papkalar shu sababli ajratilgan.

Setup yig'adigan faol Zebar widget'i — `attaquer-solid-ts`; u
`setup.json`dagi `zebar.widget` bilan belgilanadi. `attaquer-buildless` va `quiet-velvet`
mavjud qo'shimcha variantlar sifatida saqlanadi, standart setup ularni
yig'maydi. `.marketplace` Zebar xizmat ma'lumotlari uchun ishlatiladi.
Variantni o'chirishdan oldin GlazeWM startup buyrug'i va Zebar tanlovini tekshirish kerak.

## Tekshirish

`tests/run.ps1` — PowerShell regression testlari; `bun test` — widget
harakatlari; `bun run build` — TypeScript va production build;
`tools/check-desktop-build.ps1` — build'dagi skript, JSON, ZIP va rasmlar
manba bilan bir xil ekanini tekshiradi. CI shu amallarni Windows'da bajaradi.
CI shrifti Nerd Fonts v3.4.0 arxividan olinadi, tizimga o'rnatilmaydi.

`doctor.ps1` paket buyruqlari, konfiguratsiya linklari, wallpaper'lar,
cursor ZIP variantlari, o'rnatilgan cursor fayllari, faol registry yo'llari va
desktop build'ining eskirmaganligini tekshiradi.

## Widget kodini runtime sozlamalaridan ajratish

Zebar widgetlari `widgets/zebar/` ichida, startup sozlamalari esa
`config/glzr/zebar/settings.json` ichida saqlanadi. Setup har bir widgetni
`%USERPROFILE%/.glzr/zebar/<pack>`ga alohida link qiladi va settings hamda
normalize.css fayllarini shu runtime papkaga nusxalaydi. O'zgargan fayllar
avval backup qilinadi. Eski butun Zebar papkasiga link ham backup qilinadi;
uning manba papkasi o'zgartirilmaydi. Ko'chirishdan keyin
`config/symlinks.ps1`ni qayta ishga tushirish kerak.

Git va Terminal amallari `scripts/install/` ichida; ularning manba
konfiguratsiyalari `config/git/` va `config/terminal/` ichida qoladi.
`lib/setup.ps1` funksiyalari repo yo'lini majburiy `-RepoRoot` orqali oladi.

Faol widget yo'lining asosiy manbasi `setup.json`dagi `zebar.widget`.
CI shu qiymatni o'qiydi. `Assert-ZebarConfiguration` startup pack, widget,
preset va runtime link tanlangan build bilan mosligini tekshiradi;
installer, doctor va CI undan foydalanadi. `tests/zebar.ps1` mos kelmagan
sozlamalar, eski link migratsiyasi va qayta o'rnatishni tekshiradi.
## Zebar runtime va build xatolaridan tiklanish

Runtime settings, normalize.css va widget linklari bitta migratsiya sifatida
qo'llanadi. Fayl nusxalash yoki widget linki xato bersa, avvalgi fayllar va
linklar tiklanadi. Eski butun papka linki ham qaytariladi. Qisman yozilgan
ma'lumotlar `.failed_<id>` nomida saqlanadi; link manbalariga rekursiv
operatsiya bajarilmaydi. Muvaffaqiyatli migratsiyaning backup'lari qoladi.

Doctor foydalanuvchining haqiqiy `.glzr/zebar/settings.json` faylidagi
pack, widget va presetni ham tekshiradi. Repo va runtime settings yoki
normalize.css farq qilsa WARN, settings yo'q yoki noto'g'ri bo'lsa FAIL
qaytaradi. Doctor fayllarni o'zgartirmaydi.

`bun run build` va installer `tools/build-zebar.ps1` orqali production
build'ni `.dist-stage-<id>` papkasida tayyorlaydi. Index va desktop asset
hash'lari tekshirilgandan keyin eski `dist` `.dist-backup-<id>`ga ko'chadi,
yangi build `dist` bo'ladi. Almashtirish xato bersa eski build qaytariladi;
muvaffaqiyatsiz stage tozalanadi. Oldingi build backup'i Git'dan chiqarilgan
holda saqlanadi. Bu ikki rename orasida juda qisqa bo'shliq mavjud;
operatsiya filesystem darajasida mutlaq atomic almashtirish emas.

`build:raw` ichki build buyrug'i, `dev` esa to'g'ridan-to'g'ri watch build.
Oddiy production yangilash uchun `build` ishlatiladi.

## Setup bosqichlarini tanlash

`Get-SetupStages` installer ichidagi ID, label va action'larning yagona
ro'yxatini qaytaradi. `Select-SetupStages` `-Only` yoki `-Skip` ro'yxatini
filtrlaydi: comma bilan berilgan CLI argumentlari ham qabul qilinadi,
registr farqi va takrorlangan nomlar qo'shimcha bosqich yaratmaydi.
Noma'lum nomlar, ziddiyatli parametrlar va bo'sh yakuniy tanlov log yoki
package bosqichlarini boshlashdan oldin rad etiladi.

Bootstrap ro'yxatlarni child pwsh jarayoniga bitta comma-separated string
sifatida uzatadi; `-File` uchun array forwarding muammosi shu tarzda hal
qilinadi. Bosqichlar har doim odatdagi tartibda bajariladi. Faqat tanlangan
bosqichlarga kerakli modules/theme/Zebar ma'lumotlari oldindan tekshiriladi.
Boshqa bosqichlar dependency sifatida yashirincha qo'shilmaydi; dastlabki
PowerShell/repo/Scoop tayyorgarligi esa kerak bo'lsa saqlanadi.

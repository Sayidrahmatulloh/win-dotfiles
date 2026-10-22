# Loyiha arxitekturasi

Root'dagi uchta skript foydalanuvchi kirish nuqtalari: `bootstrap.ps1`
PowerShell 7'ni tayyorlaydi, `install.ps1` o'rnatish bosqichlarini bajaradi,
`doctor.ps1` esa o'zgartirmasdan tekshiradi.

## Papkalar vazifasi

| Papka | Nima saqlanadi |
| --- | --- |
| `widgets/zebar/` | Zebar dastur kodi, testlar, dependency va build vositalari |
| `config/` | Dasturlarning o'z formatidagi konfiguratsiyalar |
| `scripts/install/` | Paketlar, shriftlar, cursor, link, Git va Terminal o'rnatish bosqichlari |
| `scripts/theme/` | Windows ko'rinishini o'zgartiradigan umumiy PowerShell kodi |
| `assets/` | ZIP va rasm kabi manba fayllar, tegishli litsenziyalar |
| `themes/` | Mavzularning yagona JSON katalogi |
| `lib/core/` | Buyruq bajarish, fayl/backup, natija va hisobot yordamchilari |
| `lib/setup/` | Manifest, paket, font, link, Git, Terminal va bosqich funksiyalari |
| `lib/zebar/` | Staged build va runtime migratsiyasi |
| `lib/{utils,setup,diagnostics}.ps1` | Barqaror kutubxona kirish nuqtalari va read-only diagnostika |
| `tools/` | CI tayyorgarligi va build tekshiruvlari |
| `apps/` | Sessiyada ishlaydigan ilovalar, jumladan Walnut lock |
| `tests/powershell/` | Setup, helper, theme va diagnostika regression suite'lari |
| `tests/neovim/` | Lua tuzilma, terminal, keymap va integratsiya sinovlari |
| `tests/support/` | Suite sifatida ishga tushirilmaydigan test yordamchilari |
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
ruxsati ham yangilanadi va `tests/powershell/themes.ps1` bilan tekshiriladi.

## Neovim va Zebar variantlari

`config/nvim/init.lua` oddiy Neovim uchun `lua/standalone/`, VS Code uchun
`lua/vscode_nvim/` konfiguratsiyasini tanlaydi. Har birida `config/` va `plugins/`
alohida. Ikkalasi foydalanadigan lazy.nvim yuklovchisi, workflow aliaslari va
editing plaginlari `lua/shared/` ichida; bir muhit ikkinchisini import qilmaydi.
`lua/config/`dagi uchta kichik fayl LazyVimning standart options, keymaps va
autocmds yuklash nuqtalarini `standalone/config/`ga yo'naltiradi. Lockfile'lar
va plugin o'rnatish kataloglari har bir muhit uchun alohida saqlanadi.

Setup yig'adigan faol Zebar widget'i — `attaquer-solid-ts`; u
`setup.json`dagi `zebar.widget` bilan belgilanadi. `attaquer-buildless`
qo'shimcha variant sifatida saqlanadi, standart setup uni
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
`scripts/install/links.ps1`ni qayta ishga tushirish kerak.

Git va Terminal amallari `scripts/install/` ichida; ularning manba
konfiguratsiyalari `config/git/` va `config/terminal/` ichida qoladi.
`lib/setup.ps1` faqat `lib/setup/modules.ps1`, `lib/zebar/build.ps1` va
`lib/zebar/runtime.ps1` yordamchilarini yuklaydi. Amallar repo yo'lini majburiy
`-RepoRoot` orqali oladi. Link yaratish va directory backup qoidalari
`lib/core/files.ps1`da umumiy saqlanadi.

Faol widget yo'lining asosiy manbasi `setup.json`dagi `zebar.widget`.
CI shu qiymatni o'qiydi. `Assert-ZebarConfiguration` startup pack, widget,
preset va runtime link tanlangan build bilan mosligini tekshiradi;
installer, doctor va CI undan foydalanadi. `tests/powershell/zebar.ps1` mos kelmagan
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

`bun run build` uchun `tools/build-zebar.ps1` adapteri va installer bir xil
`lib/zebar/build.ps1` funksiyasini chaqiradi. Installer `tools/`ga bog'lanmaydi;
desktop asset tekshiruvi `lib/zebar/check-assets.ps1`da. Umumiy funksiya production
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
ro'yxatini qaytaradi. `Get-SetupStages` va `Select-SetupStages` repo yo'lini
`-RepoRoot` orqali oladi. Har descriptor o'z repo yo'lini saqlaydi; action uni
argument sifatida qabul qiladi. `Select-SetupStages` `-Only` yoki `-Skip` ro'yxatini
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

## Kod chegaralari

`Assert-SetupConfig` o'qilgan ma'lumotni tekshiradi; `Get-SetupConfig` faylni
o'qiydi va shu tekshiruvni chaqiradi. Installer'da tanlangan bosqichlar uchun
ma'lumot tekshiruvi va bosqichlarni bajarish alohida funksiyalar.

PowerShell `user_profile.ps1` kirish nuqtasi `profile/interactive.ps1`,
`environment.ps1`, `development.ps1`, `maintenance.ps1`ni yuklaydi.
Maintenance funksiyalari profil ochilganda bajarilmaydi. Modul import xatosi
haqiqiy exception bilan ko'rsatiladi.

Faol widgetning `src/index.tsx` fayli sahifani ishga tushiradi; `App.tsx`
komponentlarni joylashtiradi. `services/providers/useProviders.ts` ma'lumot manbalari,
ularning yopilishi va batareya retry timeriga egalik qiladi. Xato ko'rinishining
sof qoidalari `services/providers/health.ts`da. Media animatsiyasi komponent yonidagi
`components/Media/useMediaMarquee.ts`da saqlanadi. CSS tokenlari, animatsiyalar va icon
fontlari `src/styles/`da; layout qoidalari o'z fayllarida qoladi.

Buildless variantida status/icon tanlash qoidalari `src/status.jsx`ga ajratilgan.
Widgetlar alohida build va runtime paketlari bo'lib qoladi.

Walnut lock'da `start.ps1` lifecycle va hodisalarni boshqaradi,
`credentials.ps1` credential saqlaydi, `ui.ps1` oynalarni yaratadi. Har bir
credential amali fayl yo'lini parametr sifatida oladi. `-SelfTest` hookni
yoqishdan oldin tugaydi; regression test foydalanuvchi inputini bloklamaydi.

## Hozirgi qatlamlar va ularni kengaytirish

Root kirish skriptlari foydalanuvchi bilan ishlaydi; `scripts/` amallarni birlashtiradi;
`lib/` qayta ishlatiladigan funksiyalarni beradi. Konfiguratsiya va assetlar ma'lumot
sifatida saqlanadi. Bu yo'nalishni teskari bog'lamang: masalan, umumiy backup
funksiyasi install entry point'ini ishga tushirmasligi kerak.

`lib/utils.ps1` core va setup helperlarini, `lib/setup.ps1` post-clone module/Zebar
helperlarini yuklaydi. Doctor va kichik adapterlar kerakli aniq modulni import
qilishi mumkin. Importning o'zi install, theme almashtirish yoki build boshlamaydi.
Bootstrap esa repo hali mavjud bo'lmagan kompyuterda ishlashi sababli mustaqil qoladi.

O'rnatishning soha funksiyalari `lib/setup/{scoop,winget,fonts,links,git,terminal}.ps1`da.
`scripts/install/` ularni yuklab, argument va konfiguratsiyani uzatadigan qisqa
entry point'lardir. `lib/setup/stages.ps1` post-clone validatsiya va bajarishni
boshqaradi. `-Update`, Scoop root va font destination parametr sifatida uzatiladi;
ambient o'zgaruvchi o'rnatish xatti-harakatini o'zgartirmaydi. Hisobot va yig'ilgan
xatolar `Complete-InstallResults`, paket sikli `Sync-Packages` orqali bir joyda boshqariladi.

Paket va font amallari `Name`, `Status`, `Message` natija formatini ishlatadi.
Paket engine'i inventarning boolean natijasini va adapter qaytargan nom/statusni
tekshiradi; exceptionlarni tafsilotli `Failed` yozuviga aylantiradi. Jamlama
ro'yxatlar yagona `Entries` manbasidan hisoblanadi. Taqdimot engine'dan ajratilgan:
`-Report` orqali berilgan `Write-InstallResult` har bir yakunlangan amalni ko'rsatadi.

Link tranzaksiyasi natijani qaytaradi; `Restore-ConfigLinkBackup` tiklashni
bajaradi va band haqiqiy papkani saqlaydi. Asosiy xato, backup yo'li va rollback
xatosi natijada, keyin esa bosqich exception'ining `InstallResults` ma'lumotida
saqlanadi. PowerShell modullari ham umumiy paket sikli va natija modelini ishlatadi.

`install.ps1`ning repo yuklanishidan oldin kerak bo'ladigan Scoop/Git tayyorgarligi,
clone, bosqich tanlovi va PATH yangilashi mustaqil qoladi: bootstrap bu faylni
repo hali yo'q kompyuterga alohida yuklay oladi. Post-clone runner PATH yangilash
amalini aniq scriptblock parametri orqali oladi.

`config/symlinks.ps1` avvalgi buyruqlar uchun ikki qatorli compatibility kirish
nuqtasi. Haqiqiy link va profil amallari `scripts/install/links.ps1`da. Boshqa
`config/` skriptlari dastur talab qiladigan profil yoki startup adapterlaridir.

Faol Zebar widgetida `components/` ko'rinishni, `services/` desktop/provider
amallarini, `shared/` esa oddiy hisob va formatlashni saqlaydi. Xizmatlar
komponentlarni import qilmaydi. Variant widgetlar mustaqil entry point va build
formatlarini saqlaydi; ularni faol Solid widgetiga majburan bog'lamang.
[Widget xaritasi](../widgets/zebar/attaquer-solid-ts/README.md).

Neovim ichida ham shu qoida: `config` ulaydi, `plugins` yuklanishni e'lon qiladi,
`features` xatti-harakatni, `platform` OS moslashuvini, `ui` ko'rinishni boshqaradi.
[Neovim arxitekturasi](../config/nvim/docs/architecture.md).
LazyVim va shaxsiy tugmalar orasidagi istisnolar
`config/nvim/lua/standalone/keymaps/defaults.lua`da boshqariladi: global defaultlar
shaxsiy mappinglardan oldin o'chiriladi, plugin/LSP defaultlari o'z `keys`
spec'laridan o'chiriladi. [Keymap qoidalari](../config/nvim/docs/keymaps.md).

Yangi kod uchun qisqa tartib va tekshiruvlar: [CONTRIBUTING.md](../CONTRIBUTING.md).
Mahalliy dot-source yo'llari, kutubxona kirish nuqtalari, Neovim import yo'nalishlari
va widget xizmatlari/komponentlari orasidagi chegaralar regression testlar bilan tekshiriladi.

## Papka nomlari va o'qish tartibi

Root'da ishga tushirish buyruqlari va umumiy sozlash fayllari turadi. Kod turini
bildiradigan papka nomlari (`config`, `lib`, `scripts`, `tools`, `apps`, `tests`, `widgets`)
bir xil mas'uliyatni saqlaydi; bitta amal uchun yana parallel `helpers`, `utils`
yoki bo'sh `src` qatlami yaratilmaydi. Faylni ko'chirishning o'zi arxitektura emas:
chaqiruvchilar, yuklanish tartibi, testlar va hujjatlar ham birga o'zgaradi.

Testlar texnologiyasi bo'yicha ajratilgan: `tests/powershell/` va `tests/neovim/`.
Umumiy test kodi `tests/support/`da; `tests/run.ps1` faqat PowerShell suite'larini
yangi jarayonlarda ishga tushiradi. Widgetning testlari o'z paketi yonida qoladi.

Joriy hujjatlar `docs/`da, tarixiy qaydlar `docs/history/`da. Asosiy papkalarning
README fayli kirish nuqtasi, mas'uliyat va boshqa qatlamga bog'lanishni tushuntiradi.
Boshlash uchun [hujjatlar xaritasi](README.md), testlar uchun [tests/README.md](../tests/README.md).

Yangi PowerShell suite pastki papkadan ham `-RepoRoot` qabul qiladi. Neovim
sinovlari repo ildizini `setup.json` orqali topadi; katalog chuqurligiga yoki
foydalanuvchining kompyuteridagi mutlaq yo'lga bog'lanmaydi.

`apps/walnut-lock/` runtime ilova: launcher, supervisor va UI birga saqlanadi.
GlazeWM startup adapteri yangi yo'lni ishlatadi; konfiguratsiya junction'i va
credential joyi o'zgarmaydi. Qo'lda yaratilgan shortcut va ishlayotgan eski
supervisor uchun [migratsiya tartibi](../apps/README.md)ga qarang.

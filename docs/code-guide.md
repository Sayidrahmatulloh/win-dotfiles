# Kodni tushunish uchun yo'riqnoma

Bu repo yangi Windows kompyuterida bir xil ish muhitini tiklaydi.
Dasturlar ro'yxati va sozlamalar **ma'lumot**, ularni o'rnatadigan PowerShell
funksiyalari esa **amal** hisoblanadi. Bu ikki qism alohida saqlanadi.

## Qayerdan boshlash kerak?

1. `setup.json` — nima o'rnatiladi, konfiguratsiyalar qayerga ulanadi?
2. `install.ps1` ichidagi `Main` — bosqichlar qanday tartibda bajariladi?
3. `scripts/install/scoop.ps1` yoki `scripts/install/winget.ps1` — bitta bosqich qanday ishlaydi?
4. `lib/packages.ps1` — barcha paketlar uchun umumiy install/update sikli.
5. `doctor.ps1`, keyin `lib/diagnostics.ps1` — setup qanday tekshiriladi?

`bootstrap.ps1` faqat boshlang'ich tayyorgarlik qiladi: PowerShell 7 topadi yoki
o'rnatadi, keyin `install.ps1` ni `-NoProfile` bilan ishga tushiradi.
Yangi kompyuterda repo hali yo'q bo'lishi mumkin. Shuning uchun bootstrap va
install'ning Scoop/Git/clone qismi repo kutubxonalarini oldindan yuklamaydi.
Repo tayyor bo'lgach, qolgan funksiyalar `lib/` dan olinadi.

## Fayllarning vazifasi

| Fayl | Vazifasi |
| --- | --- |
| `setup.json` | Scoop/Winget paketlari, shriftlar, linklar, Zebar yo'li |
| `config/powershell/modules.json` | Profil, setup va doctor ishlatadigan yagona modul ro'yxati |
| `install.ps1` | Bosqichlarni ketma-ket ishga tushirish, log va yakuniy natija |
| `doctor.ps1` | Faqat tekshirish va hisobot chiqarish |
| `scripts/install/{scoop,winget}.ps1` | Paket menejeriga tegishli buyruqlar va bosqich |
| `scripts/install/fonts.ps1` | Scoop shriftlari va ZIP shriftlarini ro'yxatdan o'tkazish |
| `scripts/install/cursors.ps1` | Bibata ZIP'ni ochish va faol rangni qo'llash |
| `themes/themes.json` | Mavzu ID, ranglar, wallpaper va cursor varianti |
| `scripts/theme/ApplyTheme.ps1` | GlazeWM, wallpaper va cursor'ni birga almashtirish |
| `assets/` | Shrift arxivlari, cursor ZIP va wallpaper manbalari |
| `config/symlinks.ps1` | Papkalarni ulash va PowerShell profilini sozlash |
| `scripts/install/git.ps1` | Umumiy Git konfiguratsiyasini include qilish |
| `scripts/install/terminal.ps1` | Terminal sozlamalarini saqlash yoki tiklash |
| `lib/utils.ps1` | Setup uchun umumiy yordamchilarni yuklash |
| `lib/settings.ps1` | JSON ro'yxatlarini o'qish, link yo'llarini hisoblash |
| `lib/files.ps1` | Backup, Terminal yo'li, link manzilini tekshirish |
| `lib/packages.ps1` | Barcha menejerlar uchun yagona paket sikli |
| `lib/commands.ps1` | Buyruq chiqishi va exit code; xatoni aniq qaytarish |
| `lib/scoop.ps1` | Scoop buyruqlari; tools va fonts birga foydalanadi |
| `lib/setup.ps1` | Post-clone yordamchilarini yuklash; o'rnatish boshlamaydi |
| `lib/modules.ps1` | Yetishmayotgan PowerShell modullarini o'rnatish |
| `lib/zebar/build.ps1` | Shrift, staged build va tekshirilgan build'ni yoqish |
| `lib/zebar/runtime.ps1` | Runtime fayllari va widget linklarini tiklash imkoniyati bilan ko'chirish |
| `config/powershell/profile/` | Interaktiv profil, muhit, development va maintenance buyruqlari |
| `scripts/theme/GlazeConfig.ps1` | GlazeWM reload va focused border matnini hisoblash |
| `tools/walnut-lock/credentials.ps1` | Faqat berilgan yo'ldagi credentialni o'qish/yozish |
| `tools/walnut-lock/ui.ps1` | Oyna va ekran tasvirini yaratish |
| `lib/diagnostics.ps1` | Doctor tekshiruvlari |
| `lib/results.ps1` | Bosqich natijalari va xatolarni yig'ish |
| `lib/output.ps1` | Terminaldagi ranglar va hisobot ko'rinishi |
| `tests/helpers.ps1` | Testlar uchun umumiy loader va assertion |
| `tests/run.ps1` | Barcha testlarni alohida jarayonda ishga tushirish |

`lib/` fayllari yuklanganda o'rnatish boshlanmaydi; ular faqat funksiyalarni
e'lon qiladi. `. "$path"` (dot-source) shu funksiyalarni joriy skriptga yuklaydi.
`& "$path"` esa alohida bosqich skriptini bajaradi.

## DRY qanday qo'llanilgan?

`Sync-Packages` uchta amalni qabul qiladi:

- `IsInstalled` — paket bormi?
- `Install` — yetishmasa o'rnatish.
- `Upgrade` — faqat `-Update` berilganda yangilash.

Scoop, Winget va Fonts shu sikldan foydalanadi. Menejerga tegishli buyruqlar
alohida qoladi, natija va xatolarni yig'ish bir joyda yozilgan.
Mavjud paket oddiy setup'da qayta o'rnatilmaydi. Bir paket xato bersa, keyingisi
tekshiriladi; bosqich oxirida yig'ilgan xatolar installer'ga qaytariladi.

Terminal va Git bitta `New-ConfigBackup` funksiyasidan foydalanadi.
Setup va doctor link yo'llarini bir xil ro'yxatdan hisoblaydi va bir xil
`Test-ConfigLink` bilan manzilni tekshiradi. Papkani ko'chirish bilan fayldan
nusxa olish turli amallar bo'lgani uchun symlink backup'i alohida saqlangan.

## Yangi dastur qanday qo'shiladi?

Scoop dasturi uchun `setup.json` dagi `scoop.packages` ga nomini qo'shing.
Winget ilovasi uchun `winget` ro'yxatiga aniq paket ID'sini qo'shing.
Nerd Font uchun `scoop.fonts`, PowerShell moduli uchun
`config/powershell/modules.json` ni tahrirlang.

JSON ichida izohlar va oxirgi elementdan keyin vergul bo'lmaydi.
Paket nomi bilan executable nomi doim bir xil emas: masalan, `neovim` -> `nvim`.
Shuning uchun `requiredCommands` doctor tekshiradigan asosiy buyruqlar ro'yxati;
u to'liq paket inventari emas. Yangi buyruq muhim bo'lsa, uni ham qo'shing.

## O'zgarishni qanday tekshirish kerak?

PowerShell 7 ichida repo papkasidan:

```powershell
.\tests\run.ps1
.\doctor.ps1
```

Test, build, qo'shimcha widgetlar va o'rnatilgan Neovim integratsiyasini birga tekshirish:

```powershell
./tools/check.ps1 -Neovim -Variants
```

`-Neovim` uchun pluginlar, formatterlar va profil modullari avval o'rnatilgan
bo'lishi kerak. `tools/check-nvim.ps1` parametrsiz faqat ikki muhitning tuzilmasi
va Lua sintaksisini plugin o'rnatmasdan tekshiradi; CI shu rejimni ishlatadi.
`-Variants` qo'shimcha widget dependency'larini lockfile bilan tayyorlaydi va yig'adi.

JS/TS/CSS yozish uslubi root'dagi `.prettierrc.json`da belgilangan.
Vendordagi `zebar.js`, dependency va generatsiya qilingan buildlar formatlanmaydi.

Zebar build'i va uning desktop assetlarini tekshirish:

```powershell
bun run --cwd widgets/zebar/attaquer-solid-ts build
./tools/check-desktop-build.ps1
```

Papka vazifalari va yangi yo'llar: [architecture.md](architecture.md).

Testlar haqiqiy dasturlarni o'rnatmaydi va foydalanuvchining konfiguratsiyasini
almashtirmaydi. Ular vaqtinchalik fixture fayllari va soxta paket buyruqlaridan
foydalanadi. Doctor ham o'zgarish kiritmaydi.
To'liq install yangi Windows muhitida alohida tekshiriladi.

## Oddiy qoida

Avval mavjud yordamchi funksiyani qidiring. Takrorlanadigan amal bo'lsa umumiy
funksiya qo'shing; bitta joyda ishlatiladigan oddiy buyruqni ortiqcha qatlamga
aylantirmang. Funksiya nomi vazifani aytsin, izoh esa sababni tushuntirsin.


## Xato yuz bersa nima bo'ladi?

- Repo tayyor bo'lgach, `setup.json` va modul ro'yxati paket bosqichlaridan oldin
  tekshiriladi. Noto'g'ri tur, yo'q maydon, takrorlangan nom yoki tashqariga
  chiqadigan nisbiy yo'l aniq xato bilan to'xtaydi.
- Inventar tekshiruvi ishlamasa, install boshlanmaydi. Menejerning aniq
  "paket topilmadi" natijasigina yetishmagan paket deb olinadi.
- Paket buyruqlari xato bersa, `lib/commands.ps1` buyruq, exit code va chiqishni
  qaytaradi. Setup transcript'i shu ma'lumotni logga yozadi.
- Link yaratish ishlamasa, oldingi papka yoki link qaytariladi. Agar rollback
  ham ishlamasa, tiklash uchun backup manzili ko'rsatiladi.
- ZIP shrift fayli borligi yetarli emas: registry yozuvi ham tekshiriladi.
  Yarim qolgan o'rnatish qayta urinishda tiklanadi.
- `doctor.ps1 -DotfilesPath ...` ko'rsatilgan checkout manifestini o'qiydi.
  Manifest noto'g'ri bo'lsa, `-Json` rejimida ham tushunarli xato natijasi chiqadi.

PowerShell profilining optional modullari yo'q bo'lsa shell ochilishi davom
etadi. `Update-Scoop` xatoda keyingi cleanup bosqichlarini boshlamaydi.
C++ va Zig yordamchilari natijalarni maxsus vaqtinchalik build papkasida yaratadi;
manba yonidagi oldingi `.exe`, `.obj` va `.pdb` fayllari o'chirilmaydi.

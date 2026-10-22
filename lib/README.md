# PowerShell kutubxonalari

| Qism | Mas'uliyat |
| --- | --- |
| `core/commands.ps1` | Tashqi buyruq va exit code'ni tekshirish |
| `core/files.ps1` | Backup, link va Terminal destination yordamchilari |
| `core/results.ps1` | Natijalarni yig'ish, birlashtirish, hisobot va xatolarni uzatish |
| `core/output.ps1` | Konsoldagi hisobot ko'rinishi |
| `setup/settings.ps1` | Manifestlarni o'qish va tekshirish |
| `setup/packages.ps1` | Umumiy paket sinxronlash sikli |
| `setup/scoop.ps1` | Scoop adapterlari |
| `setup/winget.ps1` | Winget inventari, install/update adapterlari |
| `setup/fonts.ps1` | Font registratsiyasi, Scoop va ZIP font o'rnatish |
| `setup/links.ps1` | Konfiguratsiya linklari, rollback va profil entrysi |
| `setup/git.ps1` | Git include va mavjud konfiguratsiyani saqlash |
| `setup/terminal.ps1` | Terminal JSON tekshiruvi, backup va nusxalash |
| `setup/stages.ps1` | Tanlangan bosqichlar validatsiyasi va bajarilishi |
| `setup/modules.ps1` | PowerShell modullarini o'rnatish |
| `zebar/build.ps1` | Staged production build va tekshirish |
| `zebar/check-assets.ps1` | Installer va dev/CI uchun umumiy desktop asset tekshiruvi |
| `zebar/runtime.ps1` | Runtime migratsiyasi va rollback |
| `diagnostics.ps1` | Read-only doctor tekshiruvlari |

Barqaror kirish nuqtalari: `utils.ps1` umumiy helperlarni, `setup.ps1` esa
post-clone helperlarini yuklaydi. Faqat bitta modul kerak bo'lsa, uni bevosita
dot-source qilish mumkin. Importning o'zi o'rnatish yoki desktop amalini boshlamaydi.

Install ketma-ketligi `../install.ps1` va `../scripts/install/`ga tegishli.
Kutubxona funksiyalari shu entry point'larni orqaga chaqirmaydi.
Installer va kutubxona `tools/`ga bog'lanmaydi; dev/CI buyruqlari kutubxonani chaqiradi.

`lib/` umumiy funksiyalar papkasi vazifasini bajaradi. `core/` texnik
yordamchilarni, `setup/` o'rnatish sohalariga tegishli funksiyalarni ajratadi.
Parallel `functions/` papkasi yaratish o'rniga kerakli soha faylini tanlang.

`scripts/install/` fayli parametrlarni qabul qiladi, kerakli kutubxonani yuklaydi
va funksiyani chaqiradi. Funksiya `$Update`, `$SCOOP_ROOT` yoki `$SYSTEM_FONTS`
kabi chaqiruvchining o'zgaruvchilariga tayanmaydi: tanlov va yo'llar parametr
orqali beriladi. `Complete-InstallResults` hisobot va yig'ilgan xatolarni,
`Sync-Packages` esa install/update siklini bir joyda boshqaradi.

Paket adapterlari `New-InstallResult` orqali `Name`, `Status`, `Message`
maydonlariga ega natija qaytaradi. Status `Installed`, `Upgraded` yoki `Latest`;
buyruq xatosi exception sifatida uzatiladi. `Test-*` inventar funksiyalari faqat
boolean qaytaradi. Engine har bir xatoni `Failed` natijaga aylantirib, keyingi
paketni davom ettiradi; natijaning `Entries` ro'yxatida xato sababi ham qoladi.
`Entries` yagona saqlanadigan manba; `Installed`, `Upgraded`, `Latest`, `Failed`
faqat undan hisoblanadigan, yozilmaydigan ko'rinishlardir. Natijani
`Add-InstallResult` bilan qo'shing; ro'yxatlarni bevosita o'zgartirmang.
Noto'g'ri nom/status, eski boolean action natijasi va aralash stdout muvaffaqiyat
sifatida qabul qilinmaydi.

`Sync-Packages` konsolga yozmaydi. Uning ixtiyoriy `-Report` callback'i natijani
ko'rsatish uchun `lib/core/output.ps1`dagi `Write-InstallResult`ni chaqiradi.
`Complete-InstallResults` bosqich hisobotidan keyin yig'ilgan xatolarni installerga
uzatadi. `Install-FontFile` ham shu natija formatini ishlatadi; fayl nusxalash
va registry registratsiyasi `Copy-UserFontFile` va `Register-UserFont`ga ajratilgan.

`New-Symlink -Src -Dst` tashqi ro'yxatlarni o'zgartirmaydi va hisobot chiqarmaydi.
U backup va link yaratishni boshqarib, tiklashni `Restore-ConfigLinkBackup`ga
topshiradi. Natijada `Message`, `BackupPath` va `RollbackError` saqlanadi;
band haqiqiy papka tiklash uchun o'chirilmaydi. Bosqich xatosining
`Exception.Data['InstallResults']` maydoni va `Invoke-Step`ning `Results` maydoni
shu tafsilotlarni yuqori qatlamga olib chiqadi.

`Install-PSModule -Name -Repository` bitta modulni o'rnatadi va mavjudligini
tekshiradi. `Install-PSModules -RepoRoot -Repository` esa manifest, umumiy paket
sikli va bosqich hisobotini birlashtiradi. Import o'rnatishni boshlamaydi.

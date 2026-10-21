# PowerShell kutubxonalari

| Qism | Mas'uliyat |
| --- | --- |
| `core/commands.ps1` | Tashqi buyruq va exit code'ni tekshirish |
| `core/files.ps1` | Backup, link va Terminal destination yordamchilari |
| `core/results.ps1` | Bosqich natijalarini yig'ish |
| `core/output.ps1` | Konsoldagi hisobot ko'rinishi |
| `setup/settings.ps1` | Manifestlarni o'qish va tekshirish |
| `setup/packages.ps1` | Umumiy paket sinxronlash sikli |
| `setup/scoop.ps1` | Scoop adapterlari |
| `setup/modules.ps1` | PowerShell modullarini o'rnatish |
| `zebar/build.ps1` | Staged production build va tekshirish |
| `zebar/runtime.ps1` | Runtime migratsiyasi va rollback |
| `diagnostics.ps1` | Read-only doctor tekshiruvlari |

Barqaror kirish nuqtalari: `utils.ps1` umumiy helperlarni, `setup.ps1` esa
post-clone helperlarini yuklaydi. Faqat bitta modul kerak bo'lsa, uni bevosita
dot-source qilish mumkin. Importning o'zi o'rnatish yoki desktop amalini boshlamaydi.

Install ketma-ketligi `../install.ps1` va `../scripts/install/`ga tegishli.
Kutubxona funksiyalari shu entry point'larni orqaga chaqirmaydi.

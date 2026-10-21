# Ishlab chiqish va xizmat vositalari

Repo ildizidan:

| Buyruq | Vazifa |
| --- | --- |
| `./tools/check.ps1` | PowerShell testlari, asosiy widget test/typecheck/build va asset tekshiruvi |
| `./tools/check.ps1 -Neovim -Variants` | Neovim integratsiyasi va qo'shimcha widget build'ini ham tekshirish |
| `./tools/check-nvim.ps1` | Pluginlarsiz Neovim tuzilma, keymap va terminal sinovlari |
| `./tools/check-nvim.ps1 -Integration` | O'rnatilgan Neovim pluginlari bilan tekshirish |
| `./tools/check-desktop-build.ps1` | Tayyor build assetlarini manbalar bilan solishtirish |
| `./tools/build-zebar.ps1` | Tekshirilgan production build'ni tayyorlash va yoqish |
| `./tools/prepare-ci-font.ps1` | Build uchun font assetini tayyorlash |
| `./tools/repair-nvim.ps1` | Neovim parser/shell repair amallari; kundalik tekshiruv emas |

Bu fayllar qulay kirish buyruqlari. Umumiy amallar `lib/`da, tekshiruvlarning
suite'lari `tests/`da saqlanadi. Build va repair buyruqlari fayllarni o'zgartirishi mumkin.

`walnut-lock/` — o'z launcher, UI va [qo'llanmasi](walnut-lock/README.md) bor
alohida Windows yordamchi vositasi. Uning ichki kodini umumiy setup helperlari bilan
aralashtirmang.

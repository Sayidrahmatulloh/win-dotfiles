# Testlar

```text
tests/
  run.ps1          PowerShell suite'lari uchun barqaror kirish buyrug'i
  powershell/      Installer, kutubxona, theme va diagnostika regression suite'lari
  neovim/          Lua tuzilma, keymap, terminal va integratsiya tekshiruvlari
  support/         Test assertion va funksiya yuklash yordamchilari
```

Repo ildizidan PowerShell 7 orqali:

```powershell
./tests/run.ps1
./tools/check-nvim.ps1
./tools/check-nvim.ps1 -Integration
```

Bitta PowerShell suite yoki Neovim tekshiruvi:

```powershell
./tests/powershell/settings.ps1
nvim --headless -u NONE -i NONE -n -l tests/neovim/structure.lua standalone
```

`run.ps1` faqat `powershell/`dagi suite'larni, har birini alohida jarayonda bajaradi.
`support/`dagi fayllar suite sifatida ishga tushirilmaydi. Neovim runner'i
`tools/check-nvim.ps1`; oddiy rejim plugin talab qilmaydi, integration mavjud
plugin va shell vositalaridan foydalanadi.

Widget testlari o'z loyihasi yonida qoladi:

```powershell
bun test --cwd widgets/zebar/attaquer-solid-ts
```

Testlar fixture va mocklardan foydalanadi. Walnut self-test Windows DPAPI uchun
foydalanuvchi profiliga kirishni talab qiladi, lekin input lock'ni yoqmaydi.
`powershell/architecture.ps1` papka chegaralari, mahalliy importlar va hujjat
havolalarini ham tekshiradi. Yangi suite qo'shganda haqiqiy foydalanuvchi
konfiguratsiyasini o'zgartirmang.

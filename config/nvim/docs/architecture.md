# Konfiguratsiya arxitekturasi

Maqsad: bir vazifani o'zgartirish uchun kerakli joyni tez topish va boshqa muhitga
xalaqit bermaslik. Har bir papka konfiguratsiyadagi aniq mas'uliyatni bildiradi.

## O'qish tartibi

1. `../init.lua` muhitni tanlaydi: `standalone` yoki `vscode_nvim`.
2. Muhitning `init.lua` fayli startup tartibini ko'rsatadi.
3. `config/lazy.lua` umumiy va muhitga tegishli plugin spec'larini import qiladi.
4. `plugins/` kerakli plagin va yuklanish shartlarini e'lon qiladi.
5. `features/`dagi modullar foydalanuvchi amallarini bajaradi; `ui/` ko'rinishni beradi.

## Papkalar mas'uliyati

| Qism | Vazifa | Qoida |
| --- | --- | --- |
| `lua/config/` | LazyVimning standart options, keymaps, autocmds hook'lari | Bu yerda faqat tegishli modulni ulash bor |
| `shared/` | Umumiy options, ranglar, keymap yordamchisi, workflow va editing plaginlari | Hech qaysi muhitni import qilmaydi |
| `standalone/config/` | Native Neovim startup va hook'larni ulash | Imkoniyatlarning ichki kodini bu yerga yig'mang |
| `standalone/keymaps/` | Tugmalarni vazifalar bilan bog'lash | Sessiya va oyna algoritmlari `features/`da qoladi |
| `standalone/features/files/` | Explorer, picker ko'rinishi va ignore filtri | Umumiy popup va rang yordamchilaridan foydalanadi |
| `standalone/features/terminal/` | Terminal sessiyalari, geometriyasi va buffer tugmalari | Shell jarayonini ToggleTerm bajaradi |
| `standalone/platform/` | OS va shellga tegishli moslashtirish | UI, features yoki plugin spec'larini import qilmaydi |
| `standalone/plugins/` | Plugin nomi, dependency, event, opts va plugin tugmalari | Murakkab xatti-harakat feature yoki platform modulida bo'ladi |
| `standalone/ui/` | Popup o'lchamlari, rang yuzalari, winbar | Sessiyalarni va feature'larni boshqarmaydi |
| `vscode_nvim/` | VS Code API orqali bajariladigan amallar | Standalone UI yoki LazyVimni import qilmaydi |

`shared/` eng pastdagi umumiy qatlam. `features/` `ui/`, `platform/` va `shared/`dan
foydalanishi mumkin; ulardan hech biri yuqoridagi feature'ni qayta import qilmaydi.
`plugins/` va `config/` shu qismlarni birlashtiradi. Aylana importlar taqiqlangan.

Bitta vazifa uchun bitta modul yetarli bo'lsa, yangi papka yoki abstraksiya kerak emas.
Bir nechta aniq mas'uliyati paydo bo'lgan feature ichki qismlarga ajratiladi.

## Terminal qanday tuzilgan?

Fayllar paneli ham editor ustidagi floating oynadir. Layout `plugins/picker.lua`da,
editorga fokusni qaytarish va kenglikni o'zgartirish `features/files/explorer.lua`da.
`Space fe` panelga fokus beradi, `w` uni yopmasdan faylga qaytaradi. Panelning
z-index'i terminalnikidan past: terminal ochilganda ustidan ko'rinadi.

- `features/terminal/init.lua`: yaratish, yashirish, sessiya tanlash, fokus va fullscreen amali.
- `features/terminal/layout.lua`: o'lchamlar, pastki joylashuv va fullscreen holati.
- `features/terminal/keymaps.lua`: terminal bufferiga tegishli tugmalar.
- `plugins/toggleterm.lua`: ToggleTerm options va `Space t...`, `Space 1/2/3` deklaratsiyalari.
- `keymaps/terminal.lua`: LazyVim default'laridan keyin `Ctrl+/` va `Ctrl+_`ni ulash.
- `platform/shell.lua`: PowerShell executable topish va Neovim shell options.

PowerShell profilingiz `config/powershell/`da, bu Neovim papkasidan tashqarida.
PSReadLine Vi rejimi buyruq satrini tahrirlaydi; Neovim Normal rejimi terminal
chiqishini ko'rish va nusxalashga xizmat qiladi. `Esc` PowerShell'ga yetib boradi;
`Ctrl+g` Neovim Normal rejimiga o'tkazadi. Oyna yashirilsa sessiya davom etadi;
Neovim qayta ishga tushganda avvalgi shell jarayonini tiklash bu konfiguratsiyaning vazifasi emas.

## Umumiy workflow

`shared/workflow.lua` umumiy tugmalar va VS Code command ID'larini saqlaydi.
Standalone uchun haqiqiy amallar `standalone/keymaps/workflow.lua`da.
VS Code uchun `vscode_nvim/config/keymaps.lua` command ID'ni extension API'siga uzatadi.
Shu yo'l bilan umumiy modul ikkala muhitdan mustaqil qoladi.

VS Code'ga xos qo'shimcha buyruqlar `vscode_nvim/keymaps/commands.lua` jadvalida;
Vim harakatlari va visual search `vscode_nvim/keymaps/editor.lua`da.

## LazyVim va shaxsiy keymaplar

`standalone/keymaps/defaults.lua` almashtirilgan LazyVim tugmalarining yagona
ro'yxati. `config/keymaps.lua` avval shu modulning `setup()` funksiyasini,
keyin shaxsiy editor, terminal, workspace va umumiy workflow mappinglarini yuklaydi.
Shu tartibda shaxsiy mappinglar oxirgi bo'lib o'rnatiladi.

Global standartlar `vim.keymap.del` orqali, plagin standartlari esa `keys`dagi
`{ lhs, false }` bilan o'chiriladi. `plugins/picker.lua` Snacks uchun,
`plugins/lsp.lua` esa `servers["*"].keys` orqali LSP uchun shu ro'yxatdan foydalanadi.
Bu lazy loading yoki LSP attach paytida keraksiz tugmalar qayta o'rnatilishining oldini oladi.
O'rnatilgan LazyVim manbalari tahrirlanmaydi; shaxsiy muqobil tugmalar saqlanadi.

Amallar jadvali va yangi istisno qo'shish tartibi: [keymaps.md](keymaps.md).

## Yangi imkoniyat qo'shish

1. Qaysi muhitga tegishli ekanini aniqlang. Umumiy editing plagini `shared/plugins/`ga tushadi.
2. Plugin uchun `plugins/<vazifa>.lua` qo'shing. lazy.nvim shu papkadagi spec'larni avtomatik import qiladi.
3. Callback murakkablashsa, uni `features/<vazifa>/`ga chiqaring. Options va yuklanish shartlari spec'da qoladi.
4. OS'ga bog'liq ishni `platform/`ga, umumiy ko'rinish hisobini `ui/`ga joylang.
5. Tugma pluginni yuklashi kerak bo'lsa uning `keys` spec'ida, LazyVim default'ini almashtirsa `keymaps/`da yoziladi.
6. README'dagi tegishli yo'l va tugma jadvalini yangilang, tekshiruvlarni ishga tushiring.

Plugin callback'larida kerak bo'ladigan tashqi modullarni callback ichida `require` qiling.
Oddiy yordamchi modullar imkon qadar import vaqtida oyna ochmasin, shell boshlamasin
va global keymap o'rnatmasin; bunday ishlar `setup`, `attach` yoki aniq amalda bajariladi.
Options/autocmds kabi framework hook'lari bundan tabiiy istisno.

## Tekshiruvlar

Repo ildizidan:

```powershell
./tools/check-nvim.ps1
./tools/check-nvim.ps1 -Integration
```

Oddiy tekshiruvlar tarmoq yoki plugin o'rnatishni talab qilmaydi:

- `tests/neovim/architecture.lua`: mahalliy importlar mavjudligi, muhit/qatlam chegaralari va import aylanalari.
- `tests/neovim/parsers.lua`: Windows bloklagan parserlar, mavjud parserlar va takroriy setup zaxira yo'li.
- `tests/neovim/structure.lua`: ikkala startup yo'li, LazyVim hook'lari, workflow va plagin deklaratsiyalari.
- `tests/neovim/keymaps.lua`: shaxsiy tugmalar saqlanishi va keraksiz standartlar o'chirilishi;
  integration rejimida haqiqiy LazyVim va birlashtirilgan LSP key spec'lari ham tekshiriladi.
- `tests/neovim/terminal.lua`: real Neovim floating oynalari, shell backend o'rnidagi test adapteri bilan;
  yaratish, yashirish, sessiya tanlash, fokus, fullscreen va sessiya tugashidan keyingi fallback.

Integration tekshiruvlari mavjud plaginlar, PowerShell profili va tashqi vositalardan foydalanadi.
Plugin versiyalari native `lazy-lock.json` va VS Code `lazy-lock-vscode.json`da saqlanadi;
refactor paytida versiyalarni yangilash talab qilinmaydi.

Lua uslubi `config/nvim/stylua.toml`da: ikki bo'sh joy indent, 120 ustun.

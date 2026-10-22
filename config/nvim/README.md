# Neovim configuration

Terminaldagi Neovim va VS Code Neovim uchun alohida muhitlar, umumiy tahrirlash sozlamalari bilan.
`init.lua` muhitni tanlaydi; har bir muhit o'z ishga tushish tartibi va plaginlariga egalik qiladi.

## Qayerni tahrirlash kerak?

| O'zgarish | Fayl yoki papka |
| --- | --- |
| Terminal sessiyalari va oynalar orasida o'tish | `lua/standalone/features/terminal/init.lua` |
| Terminal balandligi, floating joylashuvi, fullscreen | `lua/standalone/features/terminal/layout.lua` |
| Terminal ichidagi `Esc`, `Ctrl+g`, `Ctrl+k` | `lua/standalone/features/terminal/keymaps.lua` |
| `Space tt`, `tn`, `ts`, `tf`, `1/2/3` | `lua/standalone/plugins/toggleterm.lua` |
| Sidebar va fayl qidiruvi | `lua/standalone/features/files/` |
| `.gitignore` filtri | `lua/standalone/features/files/ignore.lua` |
| Neovim tugmalari | `lua/standalone/keymaps/` |
| O'chirilgan LazyVim standart tugmalari | `lua/standalone/keymaps/defaults.lua` |
| VS Code buyruq tugmalari | `lua/vscode_nvim/keymaps/commands.lua` |
| Ikkala muhitdagi umumiy workflow tugmalari | `lua/shared/workflow.lua` |
| Shrift, indent, satrlar va editor options | `lua/standalone/config/options.lua` |
| PowerShell topish va shell sozlash | `lua/standalone/platform/shell.lua` |
| Windows bloklagan parserlar uchun zaxira yo'l | `lua/standalone/platform/treesitter.lua` |
| Popup, sarlavha va rang yuzalari | `lua/standalone/ui/` |
| Ranglar | `lua/shared/colors.lua`, `lua/standalone/plugins/theme.lua` |
| Plagin, uning options va yuklanish sharti | Tegishli muhitning `plugins/` papkasi |

## Tuzilma va yuklanish

```text
init.lua
lua/
  config/            LazyVim talab qiladigan uchta kirish hook'i
  shared/            Ikkala muhitga umumiy sozlamalar va plaginlar
  standalone/
    init.lua         Oddiy Neovim kirish nuqtasi
    config/          LazyVim setup, options, autocmds va keymaplarni ulash
    features/        Terminal va fayllar bilan ishlash xatti-harakatlari
    keymaps/         Editor, workspace va terminal tugmalari
    platform/        Windows / PowerShell moslashtirishlari
    plugins/         lazy.nvim plagin deklaratsiyalari
    ui/              Ko'rinish uchun umumiy kichik yordamchilar
  vscode_nvim/
    init.lua         VS Code kirish nuqtasi
    config/          VS Code setup, options va autocmds
    keymaps/         Vim harakatlari va VS Code command ID'lari
    plugins/         Faqat VS Code uchun plagin sozlamalari
```

O'qishni `init.lua` → `standalone/init.lua` → `standalone/config/lazy.lua`dan boshlang.
LazyVim `lua/config/{options,keymaps,autocmds}.lua` hook'larini o'zi chaqiradi;
ular tegishli `standalone/config/` moduliga o'tkazadi.
VS Code esa `vscode_nvim/init.lua` orqali o'z sozlamalarini aniq tartibda yuklaydi.

Modullar vazifasi, bog'lanish qoidalari va yangi imkoniyat qo'shish tartibi:
[arxitektura qo'llanmasi](docs/architecture.md).

`vscode` nomi extension API'siga tegishli: `lua/vscode.lua` yoki `lua/vscode/` yaratmang.
VS Code plaginlari `lazy-vscode/` va `lazy-lock-vscode.json` bilan alohida saqlanadi.

## Ko'rinish va ishlash

- Catppuccin asosida VS Code'ga mos qoramtir fon, yashil aksent va Monokai uslubidagi kod ranglari.
- Editor, o'ngdagi fayllar paneli, qidiruv va popup fonlari bir xil `#0B1015`.
- O'ng tomonda floating fayllar paneli avtomatik ochiladi; loyiha nomi faqat ildiz papkada ko'rinadi.
  Panel kod ustida turadi va editor o'lchamini o'zgartirmaydi. Terminal uning ustida ochiladi.
- `.gitignore`dagi fayl va papkalar explorer, fayl/matn qidiruvi va yaqindagi fayllarda
  yashiriladi; Git reposi bo'lmagan papkalarda ham `fd --no-require-git` ishlatiladi.
  `node_modules` va `.git` doim yashiriladi. `I` bu majburiy filtrni o'chirmaydi.
  Oddiy, ignore qilinmagan dotfile'lar panelda ko'rinadi. `fd` setup orqali o'rnatiladi.
- Editor tepasida fayl ikonkasi, nomi va papka yo'li ko'rinadi.
- Charmed / VS Code uslubidagi rangli Nerd Font ikonlar explorer, fayl qidiruvi
  va fayl sarlavhasida bir xil; maxsus loyiha papkalari alohida belgilar bilan ko'rsatiladi.
- Fayl qidiruvi VS Code Quick Open uslubida: ixcham panel, yashil qidiruv chegarasi,
  fayl ikonkasi va o'ngga tekislangan papka yo'li; preview va natijalar hisoblagichi yashirilgan.
- Qidiruv satri bir qatorli; bo'sh turganda yordamchi matn ko'rinadi. Uzun papka
  yo'llari fayl nomini yopmasligi uchun qisqartiriladi. Panel ekran kengligiga moslashadi.
- `:` buyruq satri va qidiruv maydoni bir xil kenglik, balandlik va joylashuvdan
  foydalanadi (`lua/standalone/ui/popup.lua`); oyna o'lchami o'zgarsa qayta hisoblanadi.
- Inputlar bir qatorli va ichki bo'sh sarlavhasiz; terminalning `font.cellHeight`
  qiymati `2.0` bo'lib, yumaloq chegaralar bilan ham ixchamroq ko'rinadi.
- Relative raqamlar, 2 probel, kursor atrofida 5 qator.
- Pastda umumiy status bar ko'rinadi; `:` uchun markazdagi buyruq oynasi saqlangan.
- Tablar, dashboard, indent chiziqlari, Git belgilar va avtomatik popup yo'q.
- Diagnostika saqlanadi, lekin kod orasida ko'rinmaydi; talab bo'yicha ochiladi.
- LSP, Treesitter, surround, qidiruv va saqlashda formatlash LazyVim orqali ishlaydi.
- Completion faqat inline: yozayotganda satr ichida taklif ko'rinadi; dropdown ochilmaydi.
  Taklifni qabul qilish `Tab` yoki `Ctrl+y`, almashtirish `Ctrl+n/p`, bekor qilish `Ctrl+e`.
  Snippet ichida `Tab` / `Shift+Tab` keyingi / oldingi maydonga o'tadi.
  `Enter` yangi qator ochadi. Bu LSP/buffer completion; AI Copilot emas.
- Plagin yangilash qo'lda: `:Lazy update`.
- Windows terminali PowerShell 7'ni Microsoft Store, Scoop yoki odatdagi o'rnatish
  yo'lidan topadi. Profil, PSReadLine va `ll` aliasi yuklanadi; modul yo'llari
  Neovimning bola jarayonlari uchun qayta yaratiladi.
  Profil Scoop'dagi `modules` papkasini ham qo'shadi, shu sabab o'rnatilgan
  `posh-git`, `Terminal-Icons` va `PSFzf` yangi terminalda ham topiladi.

## Tugmalar

Which-key yordam oynasi yoqilgan: `Space`dan keyin 350ms kutsangiz, tugmalar
guruhlarini ko'rsatadi. `Space ?` esa joriy buffer mappinglarini ochadi.

Quyidagi yangi aliaslar VS Code va Neovim'da bir xil ishlaydi. Eski mappinglar
saqlangan; `Space cf` hali ham faylni yopadi, `Space cr` VS Code'da yo'lni nusxalaydi.
Shu sababli format uchun `cF`, rename uchun `cn` tanlangan.

| Guruh | Yangi tugmalar |
| --- | --- |
| Fayllar | `Space fo` qidirish, `fs` saqlash, `fn` yangi, `fl` yaqindagilar, `fe` explorer |
| Qidiruv | `Space sp` loyiha matni, `sy` symbol, `sx` diagnostika |
| Kod | `Space cn` rename, `ca` code action, `cF` format |
| Bufferlar | `Space bs` tanlash, `bd` yopish, `bn/bp` keyingi/oldingi |
| Oynalar | `Space wv/wh` split, `wd` yopish, `w=` tenglashtirish, `wj/wK` pastga/tepaga |

`Space wk` kebab-case uchun saqlandi. Vim'ning `w/b/e`, `f/t`, `ciw`, `ci"`,
`di(`, `.`, `Ctrl+o/i` tugmalarini asosiy tahrirlash vositasi sifatida ishlating.

`leader` = Space, `localleader` = vergul.

Standart va shaxsiy mappinglar orasidagi takrorlarni boshqarish:
[tugmalar qo'llanmasi](docs/keymaps.md).

| Tugma | Amal |
| --- | --- |
| `jk` / `kj` | Insert rejimidan chiqish |
| `,,` | Saqlash |
| `Space Space` | Fayl qidirish |
| `Space fg` | Loyihada matn qidirish |
| `Space fb` | Ochiq bufferlar |
| `Space fe` | Fayllar panelini ochish yoki unga fokus berish |
| `Space sd` / `Space si` | Sidebarni 4 ustunga kengaytirish / toraytirish |
| `Space rl` | Yaqinda ochilgan fayllar |
| `gn` / `gp` | Keyingi / oldingi buffer |
| `Space cf` | Bufferni yopish |
| `gd` / `gr` | Definition / references (LazyVim) |
| `Space re` | Symbol nomini o'zgartirish |
| `Space qf` | Code action |
| `Space vh` | Documentation |
| `Space vd` | Joriy qatordagi diagnostika |
| `Space pr` | Loyihadagi diagnostika |
| `Space fm` | Formatlash |
| `Space tt` / `Ctrl+/` | Kod va sidebar ustidagi floating terminalni ochish / yashirish; sessiya saqlanadi |
| `Space tn` | Loyiha papkasida yangi PowerShell sessiyasi; floating oynada ochiladi |
| `Space ts` | Terminal sessiyasini tanlash |
| `Space tf` | Terminalni ekran bo'ylab kattalashtirish / avvalgi o'lchamga qaytarish |
| `Space 1` / `Space 2` / `Space 3` | Mavjud terminal #1 / #2 / #3 ga o'tish; Normal va Terminal rejimida ishlaydi |
| Terminalda `Esc` | PowerShell Vi command rejimi: `w`, `b`, `dw`, `ciw`; `i` bilan yozishga qaytish |
| Terminalda `Esc`, `Esc` | Terminal oynasini yopish; sessiya saqlanadi |
| Terminalda `Ctrl+w` | Faol terminal sessiyasini tugatish (kill) |
| Terminalda `Ctrl+g` | Neovim Normal rejimi: terminal chiqishida yurish, qidirish va nusxalash |
| Terminalning Neovim Normal rejimida `Esc` | Terminal oynasini yashirish; sessiya saqlanadi |
| Terminalda `Ctrl+k` | Panelni yopmasdan kod oynasiga qaytish |
| Sidebar ichida `w` | Sidebarni yopmasdan chapdagi faylga qaytish |
| Sidebar ichida `\` | Ochilgan barcha papkalarni yig'ish |
| `Space ui` | Editor tepasidagi fayl nomini ko'rsatish / yashirish |
| `Space ud` | Diagnostika matni va underline'ni ko'rsatish / yashirish |
| `Space ?` | LazyVim tugmalarini ko'rish |

## HTTP so'rovlari

`.http` va `.rest` fayllari Kulala 5.3.4 orqali ishlaydi. Kursorni kerakli
so'rov blokiga qo'yib `Space rq` bosing; javob pastda yumaloq chegarali,
ustma-ust oynada ochiladi. Editor va sidebar o'lchami saqlanadi; `q` oynani yopadi.
`Space rr` oxirgi so'rovni takrorlaydi, `Space ro` javobni qayta ochadi,
`Space rE` environment tanlaydi. VS Code'dagi `Space rq` ham o'z holicha ishlaydi.

`@api = http://localhost:3000/api`, `{{api}}`, JSON body va `# @name` so'rovlari
qo'llanadi. `{{createTask.response.body.$.id}}` uchun avval `createTask` so'rovini
yuboring. Fayldagi `{{task}}` kabi o'zgaruvchilar oldindan yoki environment'da
aniqlangan bo'lishi kerak. So'rov serveri alohida ishga tushiriladi.

## Formatlash

`lua/standalone/config/lazy.lua` LazyVimning `formatting.prettier` extra'sini
yoqadi. Mason `prettier`ni o'rnatadi; JavaScript, TypeScript, JSX/TSX, JSON,
CSS/SCSS, HTML, Vue, Markdown va YAML Conform orqali formatlanadi. Lua uchun
avvalgi StyLua saqlangan. Qo'shimcha filetype sozlamalari
`lua/standalone/plugins/formatting.lua` ichida.

- `Space fm` — faylni formatlash; saqlaganda ham avtomatik ishlaydi.
- `:ConformInfo` — joriy fayl formatteri, bajariladigan dastur va xatolar.
- `:Mason` — formatterlarni o'rnatish; qo'lda `:MasonInstall prettier` ham mumkin.
- `vim.g.autoformat = false` — `standalone/config/options.lua`da avtomatik formatlashni o'chirish.

Format qoidalarini loyiha ildizidagi `.prettierrc.json`da belgilang. Masalan:

```json
{
  "semi": false,
  "singleQuote": false,
  "tabWidth": 2,
  "printWidth": 100
}
```

Conform avval loyihadagi `node_modules/.bin/prettier`ni, keyin Mason'dagi
Prettier'ni ishlatadi. `.prettierrc` va `.prettierignore` loyiha ichida saqlanadi;
Neovim uchun alohida format qoidalari kerak emas.

Svelte uchun loyiha ichida `bun add -d prettier prettier-plugin-svelte` bajaring,
so'ng `.prettierrc.json`ga `"plugins": ["prettier-plugin-svelte"]` va
`"overrides": [{"files": "*.svelte", "options": {"parser": "svelte"}}]` qo'shing.
Svelte plagini sozlanmagan bo'lsa, mavjud Svelte LSP formatlashiga qaytiladi.
VS Code Neovim formatlashni VS Code'dagi formatterga yuboradi.

## VS Code bilan bir xil editing plaginlari

Comment (`gcc`, `gc`), Exchange (`cx`, `cxx`, `X`), Flash (`s`, `S`, `gs`),
Surround (`ys`, `cs`, `ds`), Telescope (`Space st`), Text-case (`Space sc`)
va Treesitter textobjects Neovim'da ham mavjud. Umumiy sozlamalar
`lua/shared/plugins/` fayllaridan olinadi; muhitga xos yuklash qoidalari tegishli
`standalone/plugins/` yoki `vscode_nvim/plugins/` katalogida saqlanadi.

Case almashtirish: `Space wu/wl/wt/ws/wc/wp/wk` — upper, lower, title,
snake, camel, Pascal, kebab. Textobjects: `af/if`, `ac/ic`, `aa/ia`,
`al/il`, `ab/ib`; o'tish `[f` / `]f`, `[a` / `]a` va boshqa VS Code mappinglari.

Neovim multi-cursor: `Ctrl+d` yoki `Space an` keyingi mos so'zga kursor qo'shadi,
`Space ma` hamma mos so'zlarga qo'shadi, `mm` joriy kursorni yoqadi/o'chiradi,
`mcm` yoki normal rejimda `Esc` kursorlarni tozalaydi. Insert rejimida avval
`Esc` bilan normal rejimga chiqing. `Ctrl+Shift+d/l` terminal qo'llasa ishlaydi;
`Space` mappinglari terminaldan qat'i nazar ishlaydi.

Multi-cursor manbasi: https://github.com/jake-stewart/multicursor.nvim

## Ishga tushirish

Windows'dagi `%LOCALAPPDATA%/nvim` ushbu papkaga junction bo'lsa, `nvim`ni qayta
ochish yetarli. Neovim 0.11.2+, Git va loyiha bo'ylab qidiruv uchun ripgrep kerak.
`nvim` ichida `:Lazy`, `:Mason` va `:checkhealth` orqali holatni tekshiring.

`lazy-lock.json` va `lazy-lock-vscode.json` plugin commitlarini Git'da saqlaydi.
Bir xil versiyalarni tiklash uchun tegishli muhitda `:Lazy restore` bajaring.
`:Lazy update` dan keyin lockfile o'zgarishlarini tekshirib, konfiguratsiya bilan
birga commit qiling.

Lua va mavjud Svelte server sozlamalari saqlangan. Boshqa tillar uchun
`:LazyExtras` orqali faqat foydalanadigan `lang.*` paketlarini tanlang;
server va formatterlarni `:Mason` orqali o'rnating. Formatlash tegishli formatter
yoki LSP mavjud bo'lsa ishlaydi. Loyiha formatter sozlamalari ustun turadi.

Shrift, font o'lchami va qator balandligi terminal sozlamalarida boshqariladi.
VS Code'dagi 18px / 50px qator balandligi terminal Neovim konfiguratsiyasi bilan
aynan takrorlanmaydi. Markdown'dagi ma'noli oxirgi probellar saqlanadi.

Neovim: `lua/standalone/config/options.lua`, `lua/standalone/keymaps/`,
`lua/standalone/features/`, `lua/standalone/ui/` va `lua/standalone/plugins/`.
VS Code: `lua/vscode_nvim/keymaps/commands.lua`, `editor.lua`
va `lua/vscode_nvim/plugins/`. Umumiy hotkeylar: `lua/shared/workflow.lua`.

Tekshiruvlar repo ildizidagi `tests/neovim/*.lua` fayllarida: muhitlarni ajratish,
sidebar va inputlar, ignore qoidalari, HTTP, formatlash va PowerShell.

Tema: https://github.com/catppuccin/nvim

LazyVim konfiguratsiya tuzilishi: https://www.lazyvim.org/configuration
Completion sozlamalari: https://cmp.saghen.dev/configuration/completion

## Tekshirish

Repo ildizidan `./tools/check-nvim.ps1` ishga tushiring. Bu plagin o'rnatmasdan
ikkala muhitni, modul yo'llarini, qatlamlar orasidagi bog'lanishlarni va terminal
sessiyalarini tekshiradi. `./tools/check-nvim.ps1 -Integration` o'rnatilgan
plaginlar bilan sidebar, shell, fayl filtri, HTTP va formatlashni ham tekshiradi.

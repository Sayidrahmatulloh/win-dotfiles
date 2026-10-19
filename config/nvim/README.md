# Minimal Neovim

VS Code sozlamalaringizga mos, kodga e'tibor beradigan LazyVim konfiguratsiyasi.
`init.lua` muhitni avtomatik tanlaydi: VS Code uchun `vscode_nvim.config`,
oddiy Neovim uchun `standalone.config` yuklanadi.

## Papkalar tuzilishi

```text
nvim/
├── init.lua                     # Muhitni tanlash
├── lua/
│   ├── standalone/              # Terminaldagi oddiy Neovim
│   │   ├── config/              # Options, keymaps, shell, ignore va workflow
│   │   ├── ui/                  # Winbar, sidebar, picker, popup va rang yuzalari
│   │   └── plugins/             # Theme, sidebar, LSP, terminal, HTTP
│   ├── vscode_nvim/             # VS Code Neovim extension
│   │   ├── config/              # VS Code options, keymaps va autocmds
│   │   └── plugins/             # VS Code multi-cursor va Treesitter sozlamalari
│   ├── shared/                  # Ikkala muhitga umumiy
│   │   ├── bootstrap.lua        # lazy.nvim yuklovchisi
│   │   ├── colors.lua           # Ranglarning yagona manbasi
│   │   ├── options.lua          # Umumiy qidiruv, clipboard va leader sozlamalari
│   │   ├── workflow.lua         # Hotkeylar; muhit o'z amallarini uzatadi
│   │   └── plugins/             # Comment, Exchange, Flash, Surround, textobjects
│   └── config/                  # LazyVim uchun uchta kichik yuklovchi
├── colors/                      # Neovimning standart colorscheme katalogi
├── lazy-lock.json               # Standalone plugin versiyalari
├── lazy-lock-vscode.json        # VS Code plugin versiyalari
└── lazyvim.json                 # LazyVim extras va holati
```

Faqat Neovimga tegishli o'zgarishlar `standalone/`ga, faqat VS Code'dagilar
`vscode_nvim/`ga, ikkalasiga kerak bo'lgan plagin sozlamalari `shared/plugins/`ga
qo'shiladi. Har bir muhit avval umumiy plaginlarni, keyin o'z sozlamalarini yuklaydi.
Bir muhit ikkinchisining plugin katalogini import qilmaydi.
`vscode` modul nomi extension API'siga tegishli: konfiguratsiya uchun
`lua/vscode/` yoki `lua/vscode.lua` yaratmang; `vscode_nvim/`dan foydalaning.

`lua/config/options.lua`, `keymaps.lua` va `autocmds.lua` LazyVim talab qiladigan
standart kirish nuqtalaridir. Ular faqat `standalone/config/`dagi mos faylni
yuklaydi; haqiqiy sozlamalarni `standalone/` ichida tahrirlang.

`standalone/ui/` ko'rinish xatti-harakatlarini ajratadi: `winbar.lua` fayl
sarlavhasini, `picker.lua` qidiruv ro'yxatini, `explorer.lua` sidebarni,
`popup.lua` input o'lchamlarini, `surface.lua` oyna ranglarini boshqaradi.
Plugin fayllarida shu qismlar ulanadi: `picker.lua`, `completion.lua`, `ui.lua`.

Umumiy modul faqat `shared/`ga bog'lanadi; native va VS Code amallari tegishli
muhit ichida qoladi. Rang o'zgartirish uchun `shared/colors.lua`ni tahrirlang.
Quick Open manbalari bitta sozlash funksiyasidan foydalanadi, shu sabab
fayllar, yaqindagilar va bufferlar bir xil ko'rinishni saqlaydi.

## Ko'rinish va ishlash

- Catppuccin asosida VS Code'ga mos qoramtir fon, yashil aksent va Monokai uslubidagi kod ranglari.
- Editor, o'ngdagi fayllar paneli, qidiruv va popup fonlari bir xil `#0B1015`.
- O'ng tomonda fayllar paneli avtomatik ochiladi; tepada loyiha nomi.
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

| Tugma | Amal |
| --- | --- |
| `jk` / `kj` | Insert rejimidan chiqish |
| `,,` | Saqlash |
| `Space Space` | Fayl qidirish |
| `Space fg` | Loyihada matn qidirish |
| `Space fb` | Ochiq bufferlar |
| `Space ef` | Fayl explorer |
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
| `Space tt` | Pastda ustma-ust ochiladigan PowerShell terminali; editor o'lchami saqlanadi |
| Terminalda `Esc` | Terminalni yashirish va faylga qaytish; sessiya saqlanadi |
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

Neovim: `lua/standalone/config/options.lua`, `keymaps.lua`, `workflow.lua`,
`lua/standalone/ui/` va `lua/standalone/plugins/` ichidagi fayllar.
VS Code: `lua/vscode_nvim/config/keymaps.lua`
va `lua/vscode_nvim/plugins/`. Umumiy hotkeylar: `lua/shared/workflow.lua`.

Tekshiruvlar repo ildizidagi `tests/nvim-*.lua` fayllarida: muhitlarni ajratish,
sidebar va inputlar, ignore qoidalari, HTTP, formatlash va PowerShell.

Tema: https://github.com/catppuccin/nvim

LazyVim konfiguratsiya tuzilishi: https://www.lazyvim.org/configuration
Completion sozlamalari: https://cmp.saghen.dev/configuration/completion

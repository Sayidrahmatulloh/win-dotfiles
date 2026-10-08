# Minimal Neovim

VS Code sozlamalaringizga mos, kodga e'tibor beradigan LazyVim konfiguratsiyasi.
`init.lua` muhitni ajratadi: VS Code `vs.config` orqali o'z konfiguratsiyasini,
oddiy Neovim esa `config.lazy` orqali ushbu setupni yuklaydi.

VS Code Neovim sozlamalari `lua/vs/config/` ichida: `options.lua`, `keymaps.lua`,
`autocmds.lua` va `lazy.lua`. VS Code plaginlari `lua/vs/plugins/` ichida qoladi.

## Ko'rinish va ishlash

- Catppuccin Mocha: yumshoq pastel ranglar, qoramtir fon, italic commentlar.
- O'ng tomonda fayllar paneli avtomatik ochiladi; tepada fayl ikonkasi va nomi.
- Relative raqamlar, 2 probel, kursor atrofida 5 qator.
- LazyVim'ning standart chiroyli statusbari va `:` uchun markazdagi buyruq oynasi.
- Tablar, dashboard, indent chiziqlari, Git belgilar va avtomatik popup yo'q.
- Diagnostika saqlanadi, lekin kod orasida ko'rinmaydi; talab bo'yicha ochiladi.
- LSP, Treesitter, surround, qidiruv va saqlashda formatlash LazyVim orqali ishlaydi.
- Completion faqat inline: yozayotganda satr ichida taklif ko'rinadi; dropdown ochilmaydi.
  Taklifni qabul qilish `Tab` yoki `Ctrl+y`, almashtirish `Ctrl+n/p`, bekor qilish `Ctrl+e`.
  Snippet ichida `Tab` / `Shift+Tab` keyingi / oldingi maydonga o'tadi.
  `Enter` yangi qator ochadi. Bu LSP/buffer completion; AI Copilot emas.
- Plagin yangilash qo'lda: `:Lazy update`.

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
| `Space tt` | Terminal |
| Terminalda `Esc` | Terminalni yashirish va faylga qaytish; sessiya saqlanadi |
| `Space ui` | Editor tepasidagi fayl nomini ko'rsatish / yashirish |
| `Space ud` | Diagnostika matni va underline'ni ko'rsatish / yashirish |
| `Space ?` | LazyVim tugmalarini ko'rish |

## VS Code bilan bir xil editing plaginlari

Comment (`gcc`, `gc`), Exchange (`cx`, `cxx`, `X`), Flash (`s`, `S`, `gs`),
Surround (`ys`, `cs`, `ds`), Telescope (`Space st`), Text-case (`Space sc`)
va Treesitter textobjects Neovim'da ham mavjud. Umumiy sozlamalar
`lua/vs/plugins/` fayllaridan olinadi; VS Code'ga bog'liq buyruqlar yuklanmaydi.

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

Asosiy fayllar: `lua/config/options.lua`, `lua/config/keymaps.lua`,
`lua/config/autocmds.lua`, `lua/config/ui.lua`, `lua/plugins/minimal.lua`, `lua/plugins/theme.lua`.

Tema: https://github.com/catppuccin/nvim

LazyVim konfiguratsiya tuzilishi: https://www.lazyvim.org/configuration
Completion sozlamalari: https://cmp.saghen.dev/configuration/completion

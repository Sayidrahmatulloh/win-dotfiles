# Tugmalarni takrorsiz boshqarish

LazyVimning kerakli standartlari saqlanadi. Shaxsiy tugma uning o'rnini olsa,
eski variant `lua/standalone/keymaps/defaults.lua`da o'chiriladi. Shaxsiy muqobil
tugmalar (`Space Space` va `Space fo` kabi) ataylab saqlangan: ular umumiy
VS Code workflow'i bilan ham mos keladi.

## Asosiy amallar

| Amal | Shaxsiy tugma | O'chirilgan LazyVim variantlari |
| --- | --- | --- |
| Sidebarni ochish yoki fokus berish | `Space fe` | `Space e`, `Space E`, `Space fE` |
| Fayl topish | `Space Space`, `Space fo` | `Space ff`, `Space fF` |
| Yaqindagi fayllar | `Space rl`, `Space fl` | `Space fr`, `Space fR` |
| Ochiq bufferlar | `Space fb`, `Space bs` | `Space ,` |
| Loyihada matn qidirish | `Space fg`, `Space sp` | `Space /`, `Space sg`, `Space sG` |
| Buyruqlar ro'yxati | `Space sa` | `Space sC` |
| Qator diagnostikasi | `Space vd` | `Space cd` |
| Symbol nomini o'zgartirish | `Space re`, `Space cn` | LSP `Space cr` |
| Fayldagi symbollar | `Space sy` | LSP `Space ss` |
| Terminal | `Space tt`, `Ctrl+/` | Snacks `Space ft`, `Space fT` |
| Oynani bo'lish | `Space wh`, `Space wv` | `Space -`, `Space \|` |

`Space cf` Normal rejimda bufferni yopadi; Visual rejimdagi standart formatlash
olib tashlangan. Formatlash uchun `Space fm` yoki umumiy `Space cF` ishlatiladi.
`Space sd/si` sidebar o'lchamini, `Space sc` text-case picker'ni boshqaradi;
Snacks'ning shu tugmalardagi boshqa amallari plugin spec'idan o'chirilgan.

## Qaysi joyda o'chirish kerak?

1. Oddiy global LazyVim tugmasi: `defaults.lua`dagi `core` ro'yxati.
   `setup()` LazyVim default'laridan keyin, shaxsiy mappinglardan oldin ishlaydi.
2. Pluginning `keys` tugmasi: shu moduldagi `plugins` ro'yxati.
   `plugin_keys()` `{ lhs, false }` spec'larini beradi. `plugins/picker.lua`
   ularni Snacks spec'iga uzatadi; lazy loading tugmani qayta tiklamaydi.
3. LSP buffer tugmasi: `plugins.lsp` ro'yxati. `plugins/lsp.lua` ularni
   `servers["*"].keys`ga uzatadi. Global `vim.keymap.del` buffer-local LSP
   tugmasini ishonchli o'chira olmaydi.
4. Shaxsiy yangi tugma: kerakli `keymaps/` modulida yoki pluginni yuklashi
   kerak bo'lsa uning `plugins/*.lua` faylidagi `keys`da.

Masalan, global tugma uchun ro'yxat elementi:

```lua
{ "n", "<leader>cd" }, -- Personal line diagnostics is <leader>vd.
```

Plugin tugmasi uchun lazy.nvim natijasi:

```lua
{ "<leader>e", false },
```

LazyVimning o'rnatilgan manba fayllarini tahrirlamang: update ularni almashtiradi.
Ko'rinishdagi takrorni faqat Which-key'dan yashirish o'rniga haqiqiy mappingni o'chiring.

## Tekshirish

Neovim ichida `:verbose nmap <Space>fe` mapping qayerdan kelganini ko'rsatadi.
Normal, Visual va Terminal rejimlari uchun mos ravishda `:nmap`, `:xmap`, `:tmap`
ishlatiladi. LSP tugmalarini server ulangan faylda ham tekshiring.

Repo ildizidan `./tools/check-nvim.ps1` siyosat va shaxsiy mappinglarni
pluginlarsiz tekshiradi. `-Integration` haqiqiy LazyVim keymaplari va birlashtirilgan
LSP key spec'lari bilan ham sinaydi. Test: `tests/neovim/keymaps.lua`.

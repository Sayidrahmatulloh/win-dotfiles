# qutebrowser

Dark green dizayn Terminal, Neovim va Zebar standart palitrasiga mos.
Oyna sarlavha paneli yashirilgan; oynani `Alt+F4` bilan yopish mumkin.
Scoop paketi `setup.json` orqali o'rnatiladi. Config katalogi
`%APPDATA%/qutebrowser/config` manziliga ulanadi; mavjud katalog installer
tomonidan backup qilinadi. Cookie, history va sessiyalar alohida data katalogida.
Bookmark yoki quickmark mavjud bo'lsa, backup'dan yangi config katalogiga ko'chiring.
Shaxsiy fayllar Git'ga kiritilmaydi.

Scoop orqali o'rnatilgan brauzer uchun faqat konfiguratsiyalarni ulash:

```powershell
./install.ps1 -Only Symlinks
```

Brauzerni qayta oching yoki `:config-source` buyrug'ini bajaring.
`:version` sahifasida config yo'lini tekshirish mumkin.

| Tugma | Amal |
| --- | --- |
| `o` / `O` | Manzil yoki qidiruvni ochish / yangi tabda ochish |
| `f` / `F` | Havolani tanlash / yangi tabda ochish |
| `j`, `k` | Pastga, yuqoriga aylantirish |
| `J`, `K` yoki `Ctrl+j`, `Ctrl+k` | Tablar orasida o'tish |
| `d` / `u` | Tabni yopish / qayta tiklash |
| `Space`, `r` | Config'ni qayta yuklash |
| `Space`, `d` | Saytlar uchun dark mode'ni almashtirish |
| `:set` | Sozlamalarni ko'rish |

Qidiruvlar: `g so'z`, `gh loyiha`, `yt video`; oddiy matn DuckDuckGo orqali.
Ochiq tablar sessiyada saqlanadi. Bitta tab bo'lsa tab paneli yashirinadi.
Saytlar uchun dark mode ixtiyoriy; brauzer interfeysi doim to'q rangda.
Standart green palitra statik, Zebar theme tugmasiga ulanmagan.

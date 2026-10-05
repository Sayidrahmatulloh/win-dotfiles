# 🪟 Windows Dotfiles (`win-dotfiles`)

Windows 10/11 uchun mukammal sozlangan, tezkor va zamonaviy dasturchi muhiti konfiguratsiyalari.

---

## ✨ Xususiyatlar

- **Shell:** PowerShell 7+ bilan Oh My Posh (`dev.omp.json`), Vi mode, FZF qidiruvi (`Ctrl+f`, `Ctrl+r`), Git integratsiyasi (`posh-git`) va `terminal-icons`.
- **Tiling Window Manager:** [GlazeWM](https://github.com/glzr-io/glazewm) (i3/bspwm kabi klaviatura orqali boshqariladigan oynalar menejeri).
- **Status Bar:** [Zebar](https://github.com/glzr-io/zebar) + SolidJS/TypeScript asosidagi chiroyli va yengil panel (`attaquer-solid-ts`).
- **Muharrir:** [Neovim](https://neovim.io) (LazyVim bazasida) va VSCode Neovim uchun yagona optimallashtirilgan konfiguratsiya.
- **Paket Menejerlari:** [Scoop](https://scoop.sh) va [Winget](https://github.com/microsoft/winget-cli) orqali to'liq avtomatlashtirilgan dasturlar o'rnatilishi.
- **Shriftlar:** Nerd Fonts (`JetBrainsMono-NF`, `CascadiaCode-NF`, `FiraCode-NF`) va dasturlash shriftlari.

---

## 📋 Tizim talablari

- Windows 10/11 va internet.
- WinGet (Microsoft Store'dagi App Installer). Topilmasa bootstrap aniq ko'rsatma bilan to'xtaydi.
- Oddiy Windows PowerShell terminali; **Run as administrator ishlatmang**.
- Bootstrap PowerShell 7'ni WinGet orqali o'rnatadi. Ayrim ilova installer'lari zarur bo'lsa UAC chiqaradi.

## 🚀 O'rnatish

Repo mavjud bo'lsa, oddiy terminaldan:

```powershell
.\bootstrap.ps1
```

Yangi kompyuterda repo fayllari GitHub'ga push qilinganidan so'ng:

```powershell
irm https://raw.githubusercontent.com/Sayidrahmatulloh/win-dotfiles/main/bootstrap.ps1 | iex
```

Repo boshqa joyda saqlanishi kerak bo'lsa:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\bootstrap.ps1 -DotfilesPath 'D:\win-dotfiles'
```

Bootstrap mavjud PowerShell 7'ni qayta o'rnatmaydi. Installer mavjud checkoutni saqlaydi, mavjud paketlarni o'tkazib yuboradi va yetishmaganlarini o'rnatadi. Paketlarni yangilash alohida, ixtiyoriy:

```powershell
.\packages\scoop.ps1 -Update
.\packages\winget.ps1 -Update
.\fonts\fonts.ps1 -Update
```

Har bosqichning natijasi oxirida ko'rsatiladi. Xato bo'lsa jarayon 1, hammasi muvaffaqiyatli bo'lsa 0 kodi bilan tugaydi. Loglar `%LOCALAPPDATA%\win-dotfiles\logs` ichida saqlanadi. Muammoni tuzatib, bootstrap'ni qayta bajaring; konfiguratsiyalar uchun mavjud backup mexanizmi saqlanadi.

Zebar Bun va uning lockfile'i orqali yig'iladi. Build muvaffaqiyatsiz tugasa, eski `dist` borligi muvaffaqiyat deb hisoblanmaydi. Zebar uchun CaskaydiaMono Nerd Font asseti toza clone'da o'rnatilgan CascadiaMono-NF paketidan avtomatik tiklanadi.

---

## 📂 Loyiha Tuzilmasi

```text
win-dotfiles/
├── bootstrap.ps1               # Windows PowerShell -> PowerShell 7
├── install.ps1                 # Asosiy o'rnatish va natija hisoboti
├── config/
│   ├── powershell/             # PowerShell profili va Oh My Posh mavzusi
│   │   ├── user_profile.ps1    # Profil sozlamalari, aliaslar, yordamchi funksiyalar
│   │   └── dev.omp.json        # Oh My Posh mavzusi
│   ├── glzr/
│   │   ├── glazewm/            # GlazeWM konfiguratsiyasi (config.yaml)
│   │   └── zebar/              # Zebar status bari va widgetlar
│   ├── nvim/                   # Neovim va VSCode Neovim konfiguratsiyasi
│   └── symlinks.ps1            # Konfiguratsiyalarni tizim yo'llariga bog'lash skripti
├── packages/
│   ├── scoop.ps1               # CLI vositalari (git, fzf, ripgrep, node, go, rust va b.)
│   └── winget.ps1              # GUI ilovalar (VS Code, Chrome, GlazeWM, Windows Terminal)
├── fonts/
│   ├── fonts.ps1               # Tizimga shriftlarni o'rnatish skripti
│   └── files/                  # Maxsus shriftlar arxivi
└── lib/
    └── utils.ps1               # Skriptlar uchun umumiy yordamchi funksiyalar
```

---

## ⌨️ Foydali Aliaslar va Funksiyalar (PowerShell)

| Buyruq | Vazifasi |
| :--- | :--- |
| `vim` | Neovim (`nvim`) ni ochish |
| `g` | `git` qisqartmasi |
| `lg` | `lazygit` TUI oynasini ochish |
| `grep` | `ripgrep` (`rg`) orqali tezkor qidiruv |
| `cs` | `Clear-System` — tizim vaqtinchalik fayllari va savatni tozalash |
| `su` | `Update-Scoop` — barcha Scoop paketlarini yangilash va keshni tozalash |
| `which <nom>` | Buyruqning tizimdagi to'liq yo'lini ko'rsatish |
| `Invoke-Cpp <fayl.cpp>` | C++ faylni tezda kompilyatsiya qilib ishga tushirish |
| `Invoke-Zig <fayl.zig>` | Zig faylni yig'ish va ishga tushirish |

---

## 🔧 Moslashtirish va Qayta Bog'lash

Faqatgina simvolik havolalarni (symlink/junction) yangilash yoki qayta tekshirish uchun:

```powershell
.\config\symlinks.ps1
```

Ushbu skript mavjud konfiguratsiyalarni xavfsiz ravishda `.bak` nusxasini saqlab oladi va yangi fayllarni bog'laydi.

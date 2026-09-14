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

## 📋 Tizim Talablari

- **OS:** Windows 10 (21H2+) yoki Windows 11
- **Shell:** PowerShell 7.0+ (`pwsh`)
- **Huquqlar:** Administrator yoki "Developer Mode" (Dasturchi rejimi) yoqilgan bo'lishi tavsiya etiladi (symlink/junction uchun)

---

## 🚀 O'rnatish

### 1-usul: Bir qatorli avtomatik o'rnatish
PowerShell 7 ni Administrator sifatida oching va quyidagi buyruqni bajaring:

```powershell
irm https://raw.githubusercontent.com/sayidrahmatulloh/win-dotfiles/main/install.ps1 | iex
```

### 2-usul: Repozitoriyani yuklab o'rnatish
```powershell
git clone https://github.com/sayidrahmatulloh/win-dotfiles.git $HOME/win-dotfiles
cd $HOME/win-dotfiles
.\install.ps1
```

*(Eslatma: Agar repozitoriya boshqa papkada, masalan `D:\win-dotfiles` da joylashgan bo'lsa, skript uni avtomatik taniydi).*

---

## 📂 Loyiha Tuzilmasi

```text
win-dotfiles/
├── install.ps1                 # Asosiy bootstrap / o'rnatish skripti
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

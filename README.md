# 🪟 Windows Dotfiles (`win-dotfiles`)

Windows 10/11 uchun mukammal sozlangan, tezkor va zamonaviy dasturchi muhiti konfiguratsiyalari.

Loyihani birinchi marta ko'rayotgan bo'lsangiz, [kodni o'qish yo'riqnomasi](docs/code-guide.md)dan boshlang. Paket va yo'llar `setup.json` ichida; bajariladigan amallar PowerShell fayllarida saqlanadi.

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
├── bootstrap.ps1       # Windows PowerShell -> PowerShell 7
├── install.ps1         # Setup bosqichlari, log va natija
├── doctor.ps1          # O'zgartirmasdan tekshirish
├── setup.json          # Paketlar, shriftlar va konfiguratsiya yo'llari
├── config/             # Dasturlarning o'z konfiguratsiyalari
│   ├── git/            # Umumiy Git sozlamalari va ulash skripti
│   ├── terminal/       # Terminal sozlamalari va saqlash/tiklash skripti
│   ├── powershell/     # Profil, mavzu va modules.json
│   ├── nvim/           # Neovim / VS Code Neovim
│   ├── glzr/           # GlazeWM va Zebar
│   └── symlinks.ps1    # Konfiguratsiya papkalarini ulash
├── packages/           # Scoop va Winget bosqichlari
├── fonts/              # Shrift o'rnatish va ZIP arxivlar
├── lib/                # Vazifasi bo'yicha ajratilgan umumiy funksiyalar
├── docs/code-guide.md  # Kodni o'qish va kengaytirish yo'riqnomasi
└── tests/run.ps1       # Barcha regression testlarni ishga tushirish
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

## Windows Terminal

`config/terminal/settings.json` stores profiles, font preferences, keybindings,
color schemes and appearance. Fonts are installed separately by the Fonts stage.
Setup restores this file after installing Terminal; a differing existing file is
backed up beside it before replacement. Running setup again does not overwrite
an identical file. Stable packaged and unpackaged Terminal paths are detected.
Preview can be selected explicitly with `-SettingsPath`.

After changing Terminal settings, save the current configuration into the repo:

```powershell
.\config\terminal\terminal.ps1 -Mode Export
```

Restore just Terminal settings:

```powershell
.\config\terminal\terminal.ps1
```

Review exported settings before committing: custom profiles can contain personal
paths or command arguments. Use `%USERPROFILE%` for portable user paths. Built-in
color schemes and default font sizes do not need to be duplicated in the file.

## Setup diagnostics

```powershell
.\doctor.ps1
.\doctor.ps1 -Json
```

Doctor performs read-only checks for core commands, GlazeWM/Zebar executables,
PowerShell modules and profile entry, config link targets, prompt JSON, Terminal
settings, Zebar root lockfile dependencies, build entrypoint, font asset and
wallpaper files. It reports `OK`, `WARN`, or `FAIL`, with suggested repair commands.
It does not install packages, load your profile, rebuild widgets or change files.
Exit code is 1 for failures and 0 otherwise; warnings alone do not fail the run.
Use PowerShell 7. `-DotfilesPath` can check a different checkout. These are static
checks, not a complete package inventory, running-app health check or dependency
graph validation.

## Shared Git configuration

`config/git/gitconfig` stores common Git settings and aliases. Setup adds an
include to your local `~/.gitconfig`, backing up that file first. Existing name,
email and credential settings stay local. A rerun does not duplicate the include.
Run only this step with:

```powershell
.\config\git\git.ps1
```

On a new computer, set your identity once (or use a repo-local identity):

```powershell
git config --global user.name "Your Name"
git config --global user.email "your-address@example.com"
```

Shared defaults: `main` for new repositories, `nvim` as the editor, and pruning
obsolete remote-tracking branches during fetch. Existing repositories keep their
current branch and line-ending settings. Authentication must be set up separately.

| Alias | Action |
| --- | --- |
| `git st` | Short status and branch |
| `git br` | Local branches with tracking details |
| `git co <branch>` | Switch to an existing branch |
| `git lg` | Graph of commit history for all branches |
| `git last` | Latest commit with file statistics |
| `git staged` | Show staged changes |
| `git unstage <file>` | Unstage a file while keeping its edits |

The global include follows the checkout path. After moving the repo, rerun this
step and remove the old include if necessary. Repository-local settings take
precedence; later entries in a config can override earlier entries.


## Kodni tekshirish

PowerShell 7 dan barcha testlar:

```powershell
.\tests\run.ps1
```

Paket qo'shish uchun `setup.json`, modul qo'shish uchun
`config/powershell/modules.json` ni tahrirlang. Batafsil tartib
[kodni o'qish yo'riqnomasida](docs/code-guide.md).


## Setup xatolaridan tiklanish

Setup paket bosqichlaridan oldin konfiguratsiya tuzilmasini tekshiradi. Inventar
xatosi paket yo'qligi deb qabul qilinmaydi; buyruqning exit code va xato chiqishi
logda saqlanadi. Link yaratish muvaffaqiyatsiz bo'lsa oldingi konfiguratsiya
qaytariladi. ZIP shriftlarning registry yozuvi ham tekshiriladi va qayta setup
yarim qolgan ro'yxatdan o'tkazishni tuzatadi. Batafsil xatti-harakat va testlar
[kodni o'qish yo'riqnomasida](docs/code-guide.md).

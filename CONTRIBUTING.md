# Kodni o'qish va o'zgartirish

Avval [kod xaritasi](docs/code-guide.md) va [arxitektura](docs/architecture.md)ni ko'ring.
Bu repo Windows ish muhitini tiklaydi; skript manbalari va amaldagi foydalanuvchi
konfiguratsiyasi link orqali bog'langan bo'lishi mumkin.

## Kerakli joyni tanlash

| O'zgarish | Joy |
| --- | --- |
| Paketlar, fontlar, manba/destination yo'llar | `setup.json` |
| PowerShell modullari | `config/powershell/modules.json` |
| O'rnatish bosqichi | `scripts/install/` |
| Qayta ishlatiladigan file/command/result amali | `lib/core/` |
| Manifest, paket va modul qoidalari | `lib/setup/` |
| Zebar build yoki runtime migratsiyasi | `lib/zebar/` |
| Dastur konfiguratsiyasi | `config/<dastur>/` |
| Theme ma'lumoti | `themes/themes.json` |
| Theme qo'llash | `scripts/theme/` |
| Asosiy panel komponenti | `widgets/zebar/attaquer-solid-ts/src/components/` |
| Windows/Zebar provider amali | Widget `src/services/` |
| Neovim xatti-harakati | `config/nvim/lua/standalone/features/` |
| Neovim plugin sozlamasi | Tegishli muhitning `plugins/` papkasi |
| Qo'lda bajariladigan build/check/repair vositasi | `tools/` |
| PowerShell suite / Neovim sinovi | `tests/powershell/` / `tests/neovim/` |
| Test yordamchisi | `tests/support/` |
| Oldingi ish qaydi | `docs/history/` |

## Yozish qoidalari

- Avval mavjud yordamchini toping. Bitta amal uchun keraksiz wrapperlar va umumiy `helpers` kataloglari yaratmang.
- Funksiya nomi bajaradigan ishini aytsin; izoh nima uchun shunday qilinganini tushuntirsin.
- Kutubxona importi o'rnatish yoki desktop amalini boshlamasin. Jarayon entry point yoki aniq funksiyadan boshlanadi.
- Bootstrap PowerShell 5.1 bilan mos va repo yo'q holatda mustaqil ishlashi kerak; qolgan setup PowerShell 7 uchun.
- Buyruq exit code va xatolarni yashirmang. Backup, rollback va takroriy ishga tushirish qoidalarini saqlang.
- Konfiguratsiya ro'yxatlarini kod ichiga takrorlamang: setup va theme JSON'lari asosiy manba.
- Component, xizmat va umumiy hisob-kitobni ajrating. Xizmat UI komponentini import qilmasin.
- Neovim `shared/` modullari `standalone` yoki `vscode_nvim`ni import qilmasin.
- Generatsiya qilingan `dist`, dependency, vendor kutubxona va binar assetlarni kod refaktori sifatida o'zgartirmang.
- Yo'l o'zgarsa barcha importlar, fixture'lar, CI va tegishli yo'riqnomalarni yangilang.

## Tekshirish

Repo ildizida PowerShell 7 orqali:

```powershell
./tests/run.ps1
./tools/check-nvim.ps1
bun test --cwd widgets/zebar/attaquer-solid-ts
bun run --cwd widgets/zebar/attaquer-solid-ts typecheck
```

`tests/run.ps1` har bir suite'ni alohida jarayonda bajaradi. Testlar haqiqiy paket
o'rnatish va foydalanuvchi sozlamalarini almashtirish o'rniga fixture va mocklardan
foydalanadi. Walnut testi Windows DPAPI foydalanuvchi profiliga kirishni talab qiladi;
SelfTest input lock'ni yoqmaydi. Neovimning oddiy tekshiruvi plugin o'rnatmaydi.

Build va barcha o'rnatilgan integratsiyalar uchun:

```powershell
./tools/check.ps1 -Neovim -Variants
```

Bu buyruq dependency/font tayyorlash va widget build'larini ham bajaradi.
Faqat production build uchun `bun run --cwd widgets/zebar/attaquer-solid-ts build`.
`doctor.ps1` tizimni o'zgartirmay tekshiradi; uning natijasi yangi Windows'da
haqiqiy bootstrap sinovi o'rnini bosmaydi.

Lua formati `config/nvim/stylua.toml`, JS/TS/CSS formati `.prettierrc.json` bilan
belgilanadi. Tekshiruv natijasini bajarilgan, bajarilmagan va muhit sabab to'xtagan
qismlari bilan aniq yozing.

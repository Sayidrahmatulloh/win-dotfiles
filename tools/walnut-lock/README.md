# Walnut lock

Qulf paytida sichqoncha clicklari va scroll global hook orqali yutiladi. Oddiy klaviatura inputi faqat Walnut jarayoni fokusda bo‘lganda uzatiladi. To‘g‘ri koddan keyin ham barcha bosilgan tugmalar qo‘yib yuborilib, qisqa tinch interval o‘tmaguncha qoplama va hooklar saqlanadi; ochuvchi Enter yoki click orqadagi ilovaga o‘tmaydi.

`start.cmd` — bloklashni qo'lda ochish. GlazeWM ishga tushganda ham avtomatik ochiladi, Zebar yuklanishi uchun 5 soniya kutadi. Bir vaqtning o'zida faqat bitta nusxa ishlaydi.

Birinchi safar kod yaratish oynasi chiqadi; bloklash keyingi ochilishda boshlanadi. Kod repoga yozilmaydi: foydalanuvchi profilida saltlangan PBKDF2 hash DPAPI bilan shifrlanadi. `-SetupOnly` bilan kodni almashtirish mumkin.

Input va yozilayotgan belgilar ko'rinmaydi. Kodni yozib Enter bosing. Xato bo'lsa maydon tozalanadi va qisqa ovoz chiqadi. To'g'ri bo'lsa laptop va keyboard yashirinadi. Desktop tasviri faqat xotirada turadi.

Ctrl, Shift, Caps, Tab, Win, Alt va F1–F12 bloklanadi. Space, harflar, raqamlar, Enter va Backspace ochiq. Avtomatik yopilish va Ctrl+Shift+F12 orqali chiqish yo'q. Ichki tekshiruv xatosida hook bekor qilinadi.

Bu Windows xavfsizlik qulfi emas. Zaruratda Ctrl+Alt+Delete orqali Task Manager ochib, faqat `tools/walnut-lock/start.ps1` ishlatayotgan powershell.exe jarayonini tugating. Startupni o'chirish uchun GlazeWM konfiguratsiyasidagi start-walnut-lock.ps1 komandasini olib tashlang. `-Preview` klaviaturani bloklamaydi; `-SelfTest` oyna va kod tekshiruvlarini bajaradi.

Terminal chaqnashisiz ishga tushirish: `start.vbs`ni oching. GlazeWM ham `wscript.exe` orqali boshlaydi. `start.cmd` eski usul uchun qolgan (uni bosganda cmd oynasi qisqa ko'rinishi mumkin). Bloklash qoplami ikki buferli, alohida fon tozalashsiz chiziladi; GlazeWM uni tiling/reflowdan chiqaradi.

Skript PowerShell 7 ichidan to‘g‘ridan-to‘g‘ri chaqirilsa, parametrlarini saqlagan holda Windows PowerShell 5.1 STA hostiga avtomatik o‘tadi. WinForms C# kompilyatsiyasi shu hostda bajariladi; `dotnet-sdk` lockni ishlatish uchun shart emas.

Widgetlarda F12, Ctrl+Shift+I/J/C, Ctrl+U va standart kontekst menyusi cheklanadi. HTML/JS fayllari diskdan o‘qilishini bu cheklamaydi.

GlazeWM `watch.ps1` supervisorini oynasiz boshlaydi. Birinchi lock yopilgach 600 soniya kutadi va qayta lock qiladi. Faol lockni takrorlamaydi; supervisor ham mutex orqali bitta nusxada ishlaydi. Davriy bloklashni to‘xtatish uchun Task Managerda `walnut-lock/watch.ps1` ishlatayotgan powershell.exe jarayonini tugating. `start.vbs` bir martalik qo‘lda lock uchun qoladi.

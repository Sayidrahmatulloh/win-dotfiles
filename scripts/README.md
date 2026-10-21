# Bajariladigan amallar

`install/` — setup bosqichlari: Scoop, Winget, fonts, cursors, links, Git va Terminal.
`theme/` — mavzu katalogini o'qish, GlazeWM, wallpaper va cursor'ni moslashtirish.

Bosqichlarning tartibi va tanlovi `../install.ps1`da. Paket va yo'llar
`../setup.json`dan, mavzular `../themes/themes.json`dan olinadi. Qayta ishlatiladigan
file, command va rollback funksiyalari `../lib/`da qoladi.

Yangi install bosqichini alohida faylga yozing va installer ro'yxatiga qo'shing.
Entry point'ni dot-source qilish bajarilishni boshlashi mumkin; testda funksiyalarni
`tests/support/powershell.ps1`dagi loader orqali ajratib yuklang.

Bootstrap repo hali yo'q paytda ham ishlashi kerak. Uning dastlabki tayyorgarligini
repo ichidagi kutubxonaga majburan bog'lamang.

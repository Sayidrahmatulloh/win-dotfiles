# Runtime ilovalar

Bu papkada foydalanuvchi sessiyasida ishlaydigan mustaqil ilovalar saqlanadi.
Har bir ilovaning launcher, ichki kodi va qo'llanmasi o'z papkasida turadi.
Umumiy installer yordamchilari `lib/`da, dev/CI buyruqlari `tools/`da qoladi.

| Ilova | Vazifa |
| --- | --- |
| [walnut-lock](walnut-lock/README.md) | Windows overlay va davriy ishga tushirish supervisori |

## Avvalgi o'rnatishdan o'tish

`tools/walnut-lock/` endi `apps/walnut-lock/`da. GlazeWM startup adapteri yangi
yo'lni repo ildizidan topadi; mavjud GlazeWM junction manzili o'zgarmaydi.
`setup.json`dagi linklarni qayta yaratish talab qilinmaydi. Qo'lda yaratilgan
shortcut yoki startup buyrug'ida eski yo'l bo'lsa, yangi yo'lga almashtiring.

Eski `watch.ps1` supervisori ishlayotgan bo'lsa, uni Task Manager orqali
to'xtating va yangi `apps/walnut-lock/watch.ps1` orqali qayta boshlang yoki
Windows sessiyasiga qayta kiring. Yangi supervisorni eski nusxa bilan birga
boshlamang: ular bir xil mutex ishlatadi. GlazeWM startup buyrug'i yoqilgan
bo'lsa, keyingi sessiyada yangi yo'l ishlatiladi.

Credential `%LOCALAPPDATA%/WalnutLock/credential.dat`da qoladi. Migratsiya
credentialni qayta yaratmaydi va input lock'ni ishga tushirmaydi.

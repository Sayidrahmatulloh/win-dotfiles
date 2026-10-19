# VS Code Custom UI

`custom-ui.css` fayli VS Code panel, input, cursor va boshqa UI qoidalarini
saqlaydi. Ranglar User `settings.json` ichidagi `workbench.colorCustomizations`
orqali boshqariladi; CSS ulardan `var(--vscode-...)` bilan foydalanadi.

## Ulash

[Custom UI Style](https://github.com/subframe7536/vscode-custom-ui-style)
extension'i kerak. User `settings.json` (`%APPDATA%/Code/User/settings.json`)
ichida quyidagi importni qo'shing:

```jsonc
{
  "custom-ui-style.external.imports": ["file:///D:/win-dotfiles/config/vscode/custom-ui.css"],
}
```

Repo boshqa papkada bo'lsa, import yo'lini o'sha joyga moslang. Boshqa importlar
mavjud bo'lsa, yangi yo'lni ro'yxatga qo'shing. Ko'chirilgan qoidalarni
`custom-ui-style.stylesheet` ichida takroran saqlamang.

CSS tahriridan keyin Command Palette'dan **Custom UI Style: Reload** buyrug'ini
bajaring. Extension tashqi fayllarni avtomatik kuzatmaydi.

Shrift va oyna sozlamalari (`custom-ui-style.font.*`, `custom-ui-style.electron`)
User `settings.json` ichida qoladi.

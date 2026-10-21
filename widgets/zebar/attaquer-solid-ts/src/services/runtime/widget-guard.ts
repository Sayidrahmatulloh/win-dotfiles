// Suppress the built-in browser menu and developer-tool shortcuts in this widget.
window.addEventListener('contextmenu', (event) => event.preventDefault(), true);
window.addEventListener(
  'keydown',
  (event) => {
    const key = event.key.toLowerCase();
    const developerShortcut =
      key === 'f12' ||
      ((event.ctrlKey || event.metaKey) && event.shiftKey && ['i', 'j', 'c'].includes(key)) ||
      ((event.ctrlKey || event.metaKey) && key === 'u');
    if (developerShortcut) {
      event.preventDefault();
      event.stopImmediatePropagation();
    }
  },
  true,
);

-- Common registration defaults; individual environments own their key choices.
return function(mode, lhs, rhs, description, options)
  vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", {
    silent = true,
    desc = description,
  }, options or {}))
end

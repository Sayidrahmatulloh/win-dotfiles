-- Prose should follow the same quiet defaults as code.
pcall(vim.api.nvim_del_augroup_by_name, "lazyvim_wrap_spell")

local group = vim.api.nvim_create_augroup("minimal_nvim", { clear = true })
vim.schedule(function()
  if #vim.api.nvim_list_uis() > 0 and vim.bo.buftype == "" and vim.fn.argv(0) ~= "-" then
    require("config.ui").open_explorer()
  end
end)

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(event)
    if vim.lsp.inlay_hint then
      vim.lsp.inlay_hint.enable(false, { bufnr = event.buf })
    end
  end,
})

-- Preserve Markdown's intentional two-space line breaks and the search register.
vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  callback = function(event)
    local bo = vim.bo[event.buf]
    if bo.buftype ~= "" or not bo.modifiable or bo.filetype == "markdown" then
      return
    end
    local view = vim.fn.winsaveview()
    vim.cmd([[silent! keepjumps keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

require('trouble').setup({
    focus = true,
})
vim.keymap.set('n', 'gxx', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>')
vim.keymap.set('n', 'gXX', '<cmd>Trouble diagnostics toggle<cr>')

vim.keymap.set('n', 'grr', '<cmd>Trouble lsp_references<cr>')
vim.keymap.set('n', 'gri', '<cmd>Trouble lsp_implementations<cr>')
vim.keymap.set('n', 'grt', '<cmd>Trouble lsp_type_definitions<cr>')
vim.keymap.set('n', 'gO', '<cmd>Trouble lsp_document_symbols<cr>')

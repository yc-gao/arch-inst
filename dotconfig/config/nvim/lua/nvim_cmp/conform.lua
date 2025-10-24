local conform = require('conform')
conform.setup({
    formatters_by_ft = {
        cpp = {'clang-format'},
    },
})
vim.keymap.set('n', 'gq', function() conform.format() end)

local conform = require('conform')
conform.setup({
    formatters_by_ft = {
        cpp = {'clang-format'},
        c = {'clang-format'},
        sh = {'shfmt'},
    },
})
vim.keymap.set('n', 'gq', function() conform.format() end)

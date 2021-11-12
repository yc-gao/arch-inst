local conform = require('conform')
conform.setup({
    formatters_by_ft = {
        cpp = {'clang-format'},
        c = {'clang-format'},
        cuda = {'clang-format'},
        sh = {'shfmt'},
        python = {'autopep8'},
    },
})
vim.keymap.set('n', 'gq', function() conform.format() end)

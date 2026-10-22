return {
    'stevearc/conform.nvim',
    opts = {
        formatters_by_ft = {
            cpp = {'clang-format'},
            c = {'clang-format'},
            cuda = {'clang-format'},
            sh = {'shfmt'},
            python = {'autopep8'},
        },
    },
    keys = {
        {'gq', function() require('conform').format() end},
    }
}

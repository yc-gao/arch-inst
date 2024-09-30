return {
    'echasnovski/mini.nvim',
    version = '*',
    config = function()
        require('mini.pairs').setup()
        require('mini.move').setup({
            mappings = {
                 left = '<C-h>',
                right = '<C-l>',
                down = '<C-j>',
                up = '<C-k>',

                -- Move current line in Normal mode
                line_left = '<C-h>',
                line_right = '<C-l>',
                line_down = '<C-j>',
                line_up = '<C-k>',
            }
        })
        require('mini.align').setup()
    end,
}

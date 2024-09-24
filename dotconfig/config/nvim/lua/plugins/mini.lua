return {
    'echasnovski/mini.nvim',
    version = '*',
    config = function()
        require('mini.cursorword').setup()
        require('mini.pairs').setup()
        require('mini.align').setup()
    end,
}

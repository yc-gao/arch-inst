return {
    'morhetz/gruvbox',
    event = 'VimEnter',
    config = function()
        vim.cmd([[colorscheme gruvbox]])
    end,
}

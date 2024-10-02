return {
    'terryma/vim-expand-region',
    keys = {
        { '<A-=>', '<Plug>(expand_region_expand)', { 'n', 'v' } },
        { '<A-->', '<Plug>(expand_region_shrink)', { 'n', 'v' } },
    },
    config = function()
        vim.keymap.set({ 'n', 'v' }, '<A-->', '<Plug>(expand_region_shrink)')
        vim.keymap.set({ 'n', 'v' }, '<A-=>', '<Plug>(expand_region_expand)')
    end
}

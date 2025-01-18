return {
    'terryma/vim-expand-region',
    keys = {
        { '<A-=>', '<Plug>(expand_region_expand)', mode = {'n', 'v'} },
        { '<A-->', '<Plug>(expand_region_shrink)', mode = {'n', 'v'} },
    },
}

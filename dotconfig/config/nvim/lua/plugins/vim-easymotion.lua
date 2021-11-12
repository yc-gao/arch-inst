return {
    'easymotion/vim-easymotion',
    keys = {
        { 'ss', '<Plug>(easymotion-f2)' },
        { 'SS', '<Plug>(easymotion-bd-f2)' },
    },
    init = function()
        vim.g.EasyMotion_do_mapping = 0
    end,
}

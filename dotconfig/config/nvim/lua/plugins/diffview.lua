return {
    'sindrets/diffview.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        require('diffview').setup({
            view = {
                default = {
                    layout = 'diff2_horizontal',
                },
                merge_tool = {
                    disable_diagnostics = true,
                }
            }
        })
        vim.keymap.set('n', '<leader>do', '<cmd>DiffviewOpen<cr>')
        vim.keymap.set('n', '<leader>dc', '<cmd>DiffviewClose<cr>')
        vim.keymap.set('n', '<leader>dh', '<cmd>DiffviewFileHistory<cr>')
    end,
}

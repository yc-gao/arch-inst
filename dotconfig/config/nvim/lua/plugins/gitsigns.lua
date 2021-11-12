return {
    'lewis6991/gitsigns.nvim',
    opts = {
        on_attach = function(bufnr)
            local gitsigns = require('gitsigns')
            local opts = { buffer = bufnr }

            vim.keymap.set('n', '<leader>hh', gitsigns.preview_hunk, opts)
            vim.keymap.set('n', '<leader>hk', gitsigns.prev_hunk, opts)
            vim.keymap.set('n', '<leader>hj', gitsigns.next_hunk, opts)

            vim.keymap.set('n', '<leader>hr', gitsigns.reset_hunk, opts)
            vim.keymap.set('n', '<leader>hs', gitsigns.stage_hunk, opts)
            vim.keymap.set('n', '<leader>hu', gitsigns.undo_stage_hunk, opts)

            vim.keymap.set('n', '<leader>hR', gitsigns.reset_buffer, opts)
            vim.keymap.set('n', '<leader>hS', gitsigns.stage_buffer, opts)
        end,
    },
}

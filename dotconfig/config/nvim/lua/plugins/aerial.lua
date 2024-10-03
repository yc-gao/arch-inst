return {
    'stevearc/aerial.nvim',
    -- Optional dependencies
    dependencies = {
        'nvim-treesitter/nvim-treesitter',
        'nvim-tree/nvim-web-devicons'
    },
    config = function()
        require('aerial').setup({
            backends = { 'treesitter', 'lsp', 'markdown', 'asciidoc', 'man' },
            layout = {
                max_width = { 50, 0.3 },
                min_width = 20,
            },
            keymaps = {
                ['<CR>'] = 'actions.jump',
                ['<2-LeftMouse>'] = 'actions.jump',

                ['l'] = 'actions.tree_open',
                ['L'] = 'actions.tree_toggle_recursive',
                ['h'] = 'actions.tree_close',
                ['H'] = 'actions.tree_close_recursive',

                ['<A-j>'] = 'actions.down_and_scroll',
                ['<A-k>'] = 'actions.up_and_scroll',
            },
        })

        vim.keymap.set('n', '<leader>cm', '<cmd>AerialToggle<CR>')
    end,
}

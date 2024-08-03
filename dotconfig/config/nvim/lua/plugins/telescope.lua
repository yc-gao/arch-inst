return {
    'nvim-telescope/telescope.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope-ui-select.nvim',
        'folke/todo-comments.nvim',
        'nvim-lua/plenary.nvim'
    },
    config = function()
        local telescope = require('telescope')
        local actions = require('telescope.actions')

        telescope.setup({
            defaults = {
                mappings = {
                    i = {
                        ['<CR>'] = actions.select_default,
                        ['<Tab>'] = actions.toggle_selection + actions.move_selection_worse,
                        ['<S-Tab>'] = actions.toggle_selection + actions.move_selection_better,
                        ['<A-j>'] = actions.preview_scrolling_down,
                        ['<A-k>'] = actions.preview_scrolling_up,
                        ['<A-h>'] = actions.preview_scrolling_left,
                        ['<A-l>'] = actions.preview_scrolling_right,
                    },
                    n = {
                        ['<CR>'] = actions.select_default,
                        ['<Tab>'] = actions.toggle_selection + actions.move_selection_worse,
                        ['<S-Tab>'] = actions.toggle_selection + actions.move_selection_better,
                        ['<A-j>'] = actions.preview_scrolling_down,
                        ['<A-k>'] = actions.preview_scrolling_up,
                        ['<A-h>'] = actions.preview_scrolling_left,
                        ['<A-l>'] = actions.preview_scrolling_right,

                        ['gg'] = actions.move_to_top,
                        ['G'] = actions.move_to_bottom,
                    }
                }
            }
        })
        local builtin = require('telescope.builtin')

        vim.keymap.set('n', '<leader>ff', builtin.find_files)
        vim.keymap.set('n', '<leader>fg', builtin.live_grep)
        vim.keymap.set('n', '<leader>fb', builtin.buffers)

        vim.keymap.set('n', '<leader>gr', builtin.lsp_references)
        vim.keymap.set('n', '<leader>gd', builtin.lsp_definitions)
        vim.keymap.set('n', '<leader>gD', builtin.lsp_implementations)

        require('todo-comments').setup({})
        vim.keymap.set('n', '<leader>ft', '<cmd>TodoTelescope keywords=TODO,FIX,HACK,WARNING<CR>')
    end,
}

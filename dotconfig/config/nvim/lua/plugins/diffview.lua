return {
    'sindrets/diffview.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        local actions = require('diffview.actions')
        require('diffview').setup({
            view = {
                default = {
                    disable_diagnostics = true,
                },
            },
            keymaps = {
                disable_defaults = true,
                view = {
                    { "n", "<tab>",   actions.select_next_entry,             { desc = "Open the diff for the next file" } },
                    { "n", "<s-tab>", actions.select_prev_entry,             { desc = "Open the diff for the previous file" } },

                    { "n", "[",       actions.prev_conflict,                 { desc = "In the merge-tool: jump to the previous conflict" } },
                    { "n", "]",       actions.next_conflict,                 { desc = "In the merge-tool: jump to the next conflict" } },

                    { "n", "co",      actions.conflict_choose("ours"),       { desc = "Choose the OURS version of a conflict" } },
                    { "n", "ct",      actions.conflict_choose("theirs"),     { desc = "Choose the THEIRS version of a conflict" } },
                    { "n", "cb",      actions.conflict_choose("base"),       { desc = "Choose the BASE version of a conflict" } },
                    { "n", "ca",      actions.conflict_choose("all"),        { desc = "Choose all the versions of a conflict" } },
                    { "n", "cn",      actions.conflict_choose("none"),       { desc = "Delete the conflict region" } },

                    { "n", "cO",      actions.conflict_choose_all("ours"),   { desc = "Choose the OURS version of a conflict" } },
                    { "n", "cT",      actions.conflict_choose_all("theirs"), { desc = "Choose the THEIRS version of a conflict" } },
                    { "n", "cB",      actions.conflict_choose_all("base"),   { desc = "Choose the BASE version of a conflict" } },
                    { "n", "cA",      actions.conflict_choose_all("all"),    { desc = "Choose all the versions of a conflict" } },
                    { "n", "cN",      actions.conflict_choose_all("none"),   { desc = "Delete the conflict region" } },
                },
            },
        })
        vim.keymap.set('n', '<leader>do', '<cmd>DiffviewOpen<cr>')
        vim.keymap.set('n', '<leader>dc', '<cmd>DiffviewClose<cr>')
        vim.keymap.set('n', '<leader>dh', '<cmd>DiffviewFileHistory<cr>')
    end,
}

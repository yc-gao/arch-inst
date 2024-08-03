return {
    'kyazdani42/nvim-tree.lua',
    config = function()
        require('nvim-tree').setup({
            view = {
                adaptive_size = true,
                width = {
                    max = 50,
                },
            },
            ui = {
                confirm = {
                    remove = false
                }
            },
            update_focused_file = {
                enable = true,
            },
            live_filter = {
                always_show_folders = false,
            },
            on_attach = function(bufnr)
                local function opts(desc)
                    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr }
                end
                local api = require("nvim-tree.api")
                vim.keymap.set('n', '<esc>', '<nop>', opts('Disable esc'))
                vim.keymap.set('n', '<2-LeftMouse>', api.node.open.edit, opts('Open'))

                vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts('Close Directory'))
                vim.keymap.set('n', 'l', api.node.open.edit, opts('Open'))
                vim.keymap.set('n', 'L', api.tree.expand_all, opts('Expand All'))
                vim.keymap.set('n', 'H', api.tree.collapse_all, opts('Collapse All'))

                vim.keymap.set('n', ']', api.tree.change_root_to_node, opts('CD'))
                vim.keymap.set('n', '[', api.tree.change_root_to_parent, opts('Up'))

                vim.keymap.set('n', 'r', api.fs.rename, opts('Rename'))
                vim.keymap.set('n', 'a', api.fs.create, opts('Create'))
                vim.keymap.set('n', 'yy', api.fs.copy.node, opts('Copy'))
                vim.keymap.set('n', 'dd', api.fs.cut, opts('Cut'))
                vim.keymap.set('n', 'pp', api.fs.paste, opts('Paste'))
                vim.keymap.set('n', 'de', api.fs.remove, opts('Delete'))
                vim.keymap.set('n', 'yp', api.fs.copy.absolute_path, opts('Copy Absolute path'))
                vim.keymap.set('n', 'yr', api.fs.copy.relative_path, opts('Copy Relative path'))
                vim.keymap.set('n', 'yn', api.fs.copy.filename, opts('Copy filename'))

                vim.keymap.set('n', 'i', api.tree.toggle_gitignore_filter, opts('Toggle Git Ignore'))
                vim.keymap.set('n', '/', function()
                    api.live_filter.clear()
                    api.live_filter.start()
                end, opts('Search'))
                vim.keymap.set('n', 'R', api.tree.reload, opts('Refresh'))
            end,

        })
        vim.keymap.set('n', '<leader>dr', '<cmd>NvimTreeToggle<cr>')
    end,
    init = function()
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
        vim.opt.termguicolors = true
    end,
}

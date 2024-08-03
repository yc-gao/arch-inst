return {
    'willothy/nvim-cokeline',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-tree/nvim-web-devicons',
        'stevearc/resession.nvim'
    },
    config = function()
        local hlgroups = require('cokeline.hlgroups')

        require('cokeline').setup({
            default_hl = {
                fg = function(buffer)
                    return buffer.is_focused and hlgroups.get_hl_attr('ColorColumn', 'bg') or
                        hlgroups.get_hl_attr('Normal', 'fg')
                end,
                bg = function(buffer)
                    return buffer.is_focused and hlgroups.get_hl_attr('Normal', 'fg') or
                        hlgroups.get_hl_attr('ColorColumn', 'bg')
                end,
            },
            components = {
                {
                    text = '|'
                },
                {
                    text = function(buffer) return ' ' .. buffer.index .. ':' end,
                },
                {
                    text = function(buffer) return ' ' .. buffer.devicon.icon end,
                    fg = function(buffer) return buffer.devicon.color end,
                },
                {
                    text = function(buffer) return buffer.filename end,
                    bold = function(buffer) return buffer.is_focused end,
                    underline = function(buffer) return buffer.is_hovered end,
                },
                {
                    text = function(buffer) return buffer.is_modified and ' * ' or ' ' end,
                    bold = true,
                },
            },
            sidebar = {
                filetype = { 'NvimTree' },
                components = {
                    {
                        text = function(buf) return buf.filetype end,
                        blod = true,
                    }
                }
            }
        })
        local mappings = require('cokeline.mappings')
        for i = 1, 9, 1 do
            vim.keymap.set({ 'n', 'v' }, string.format('<A-%s>', i), function() mappings.by_index('focus', i) end)
        end
        vim.keymap.set({ 'n', 'v' }, '<A-[>', function() mappings.by_step('focus', -1) end)
        vim.keymap.set({ 'n', 'v' }, '<A-]>', function() mappings.by_step('focus', 1) end)

        vim.keymap.set({ 'n', 'v' }, '<A-S-{>', function() mappings.by_step('switch', -1) end)
        vim.keymap.set({ 'n', 'v' }, '<A-S-}>', function() mappings.by_step('switch', 1) end)

        vim.keymap.set({ 'n', 'v' }, '<A-C-[>', function() mappings.by_step('close', -1) end)
        vim.keymap.set({ 'n', 'v' }, '<A-C-]>', function() mappings.by_step('close', 1) end)
    end,
}

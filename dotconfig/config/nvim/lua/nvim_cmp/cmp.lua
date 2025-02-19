local has_words_before = function()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local luasnip = require('luasnip')
require('luasnip.loaders.from_vscode').lazy_load()
require('luasnip.loaders.from_snipmate').lazy_load()

local cmp = require('cmp')
cmp.setup({
    snippet = {
        expand = function(args) require('luasnip').lsp_expand(args.body) end
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered()
    },
    mapping = cmp.mapping.preset.insert({
        ['<Tab>'] = function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.locally_jumpable(1) then
                luasnip.jump(1)
            elseif has_words_before() then
                cmp.complete()
            else
                fallback()
            end
        end,
        ['<S-Tab>'] = function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end,
        ['<CR>'] = function(fallback)
            if cmp.visible() and cmp.get_active_entry() then
                cmp.confirm()
            else
                fallback()
            end
        end,
        -- ['<ESC>'] = cmp.mapping.abort(),
        ['<C-k>'] = cmp.mapping.scroll_docs(-4),
        ['<C-j>'] = cmp.mapping.scroll_docs(4),
    }),
    formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
            vim_item.kind = string.format('%s', vim_item.kind)
            vim_item.menu = ({
                nvim_lsp = "[LSP]",
                luasnip = "[LuaSnip]",
                nvim_lsp_signature_help = "",
                buffer = "[Buffer]",
                path = "[Path]",
                calc = "[Calc]",
                emoji = "[Emoji]",
            })[entry.source.name]
            return vim_item
        end,
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp_signature_help' },
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'path' },
        { name = 'calc' },
        { name = 'emoji' },
    }),
    sorting = {
        comparators = { cmp.config.compare.offset, cmp.config.compare.exact }
    },
})

cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'buffer' }
    })
})
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'cmdline' }
    })
})

vim.keymap.set('n', 'grn', vim.lsp.buf.rename)
vim.keymap.set('n', 'gra', vim.lsp.buf.code_action)
vim.keymap.set('n', 'gq', vim.lsp.buf.format)

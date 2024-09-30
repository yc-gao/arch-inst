local mason_init = function()
    require('mason').setup()
    require('mason-lspconfig').setup({
        ensure_installed = {
            'clangd', 'cmake',
            'pyright', 'pylsp',
            'html', 'emmet_language_server',
            'eslint', 'ts_ls',
            'cssls',
            'bashls', 'awk_ls',
            'lua_ls',
            'dockerls', 'docker_compose_language_service',
            'jsonls', 'yamlls',
        },
        automatic_installation = true
    })
    require('mason-lspconfig').setup_handlers({
        function(server_name) -- default handler (optional)
            require("lspconfig")[server_name].setup({})
        end,
        ['emmet_language_server'] = function()
            local lspconfig = require('lspconfig')
            lspconfig.emmet_language_server.setup({
                filetypes = {
                    'css', 'less', 'sass', 'scss',
                    'html', 'eruby', 'pug',
                    'javascript', 'javascriptreact',
                    'typescript', 'typescriptreact',
                },
            })
        end,
        ['html'] = function()
            local lspconfig = require('lspconfig')
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.completion.completionItem.snippetSupport = true
            lspconfig.html.setup({
                capabilities = capabilities,
            })
        end,
        ['cssls'] = function()
            local lspconfig = require('lspconfig')
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.completion.completionItem.snippetSupport = true
            lspconfig.cssls.setup({
                capabilities = capabilities,
            })
        end,
    })
end

local cmp_init = function()
    local luasnip = require('luasnip')
    require('luasnip.loaders.from_vscode').lazy_load()
    require('luasnip.loaders.from_snipmate').lazy_load()

    local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end

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
                if cmp.visible() then
                    if luasnip.expandable() then
                        luasnip.expand()
                    else
                        cmp.confirm({ select = true })
                    end
                else
                    fallback()
                end
            end,
            ['<ESC>'] = cmp.mapping.abort(),
            ['<A-k>'] = cmp.mapping.scroll_docs(-4),
            ['<A-j>'] = cmp.mapping.scroll_docs(4),
        }),
        formatting = {
            fields = { "kind", "abbr", "menu" },
            format = function(entry, vim_item)
                vim_item.kind = string.format('%s', vim_item.kind)
                vim_item.menu = ({
                    nvim_lsp = "[LSP]",
                    luasnip = "[LuaSnip]",
                    buffer = "[Buffer]",
                    path = "[Path]",
                    calc = "[Calc]",
                    emoji = "[Emoji]",
                })[entry.source.name]
                return vim_item
            end,
        },
        sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
            { name = 'buffer' },
            { name = 'path' },
            { name = 'calc' },
            { name = 'emoji' },
        }),
        sorting = {
            comparators = { cmp.config.compare.exact, cmp.config.compare.offset }
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
end

return {
    'hrsh7th/nvim-cmp',
    dependencies = {
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-emoji',
        'hrsh7th/cmp-cmdline',
        'hrsh7th/cmp-calc',

        'saadparwaiz1/cmp_luasnip',
        'L3MON4D3/LuaSnip',
        'rafamadriz/friendly-snippets',
        'honza/vim-snippets',

        'hrsh7th/cmp-nvim-lsp',
        'neovim/nvim-lspconfig',
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
    },
    config = function()
        mason_init()
        cmp_init()

        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)
        vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename)
        vim.keymap.set('n', '<leader>cm', vim.lsp.buf.format)

    end,
}

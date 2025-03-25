require('mason').setup()
require('mason-lspconfig').setup({
    ensure_installed = {
        'clangd',
        'bashls',
    },
    handlers = {
        function(server_name) -- default handler (optional)
            require("lspconfig")[server_name].setup({})
        end,
        ['emmet_language_server'] = function()
            require("lspconfig")["emmet_language_server"].setup({
                filetypes = {
                    "css", "eruby", "html", "htmldjango", "javascriptreact", "less", "pug", "sass", "scss", "typescriptreact", "htmlangular",
                    "javascript"
                },
            })
        end,
    },
})


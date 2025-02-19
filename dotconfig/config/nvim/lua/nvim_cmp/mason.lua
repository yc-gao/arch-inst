require('mason').setup()
require('mason-lspconfig').setup({
    ensure_installed = {
        'clangd',
        'bashls',
    },
    automatic_installation = true,
    handlers = {
        function(server_name) -- default handler (optional)
            require("lspconfig")[server_name].setup({})
        end,
    },
})


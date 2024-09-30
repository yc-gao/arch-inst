return {
    'ray-x/lsp_signature.nvim',
    config = function()
        -- require('lsp_signature').setup({})
        vim.api.nvim_create_autocmd('LspAttach', {
            callback = function(args)
                local bufnr = args.buf
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                require('lsp_signature').on_attach({
                    bind = true,
                    handler_opts = {
                        border = "rounded"
                    }
                vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)
                }, bufnr)
            end
        })
    end,
}

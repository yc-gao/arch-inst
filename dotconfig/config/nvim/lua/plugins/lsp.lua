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
        'hrsh7th/cmp-nvim-lsp-signature-help',
        'hrsh7th/cmp-nvim-lsp-document-symbol',
        'folke/trouble.nvim',

        'williamboman/mason-lspconfig.nvim',
        'neovim/nvim-lspconfig',
        'williamboman/mason.nvim',
        'stevearc/conform.nvim',
    },
    config = function()
        require('nvim_cmp.mason')
        require('nvim_cmp.cmp')
        require('nvim_cmp.trouble')
        require('nvim_cmp.conform')
    end,
}


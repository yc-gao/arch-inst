return {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
        require('nvim-treesitter.configs').setup({
            ensure_installed = {
                "c", "cpp", "cuda", "cmake", "make", "ninja",
                "asm",
                "python",
                "lua",
                "go",
                "css", "scss", "html", "javascript",
                "bash", "jq",
                "dockerfile",
                "json", "yaml",
                "gitignore", "git_config",
            },
            auto_install = true,
            highlight = {
                enable = true,
                disable = function(lang, buf)
                    local max_filesize = 100 * 1024 -- 100 KB
                    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                    if ok and stats and stats.size > max_filesize then
                        return true
                    end
                    return false
                end,
            },
            indent = {
                enable = true
            }
        })
        vim.wo.foldmethod = 'expr'
        vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    end
}

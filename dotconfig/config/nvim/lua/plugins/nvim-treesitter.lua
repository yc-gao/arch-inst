return {
    'nvim-treesitter/nvim-treesitter',
    config = function()
        require('nvim-treesitter.configs').setup({
            ensure_installed = {
                "c", "cpp", "cuda", "cmake", "make", "ninja",
                "python",
                "lua",
                "go",
                "css", "scss", "html", "javascript",
                "bash", "jq",
                "dockerfile",
                "gitignore",
                "json", "yaml",

            },
            auto_install = true,
            highlight = function(lang, buf)
                local max_filesize = 100 * 1024 -- 100 KB
                local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                if ok and stats and stats.size > max_filesize then
                    return true
                end
            end,
            indent = {
                enable = true
            }
        })
    end
}

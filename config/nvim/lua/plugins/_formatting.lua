return {
    {
        'stevearc/conform.nvim',
        event = { 'BufReadPre' },
        opts = {
            default_format_opts = {
                timeout_ms = 1000,
                lsp_format = 'fallback', -- LSP formatting used when no formatter is available
            },
            formatters_by_ft = {
                javascript = { 'prettierd' },
                typescript = { 'prettierd' },
                javascriptreact = { 'prettierd' },
                typescriptreact = { 'prettierd' },
                svelte = { 'prettier' },
                css = { 'prettierd' },
                html = { 'prettierd' },
                json = { 'prettierd' },
                yaml = { 'prettier' },
                markdown = { 'prettier' },
                graphql = { 'prettier' },
                lua = { 'stylua' },
                python = { 'isort', 'black' },
            },
            format_on_save = function(bufnr)
                -- Disable with a global or buffer-local variable
                if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                    return nil
                end
                return { lsp_format = 'fallback', timeout_ms = 500 }
            end,
            notify_on_error = true,
        },
        keys = {
            {
                '<leader>cf',
                function()
                    require('conform').format({ async = true, lsp_format = 'fallback' })
                end,
                mode = { 'n', 'v' },
                desc = '[F]ormat',
            },
        },
        init = function()
            vim.o.formatexpr = "v:lua.require'conform'.formatexpr()" -- formatexpr override
        end,
    },
}

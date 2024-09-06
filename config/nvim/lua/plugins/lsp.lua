return {
    -- LSP configuration & plugins
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            -- Automatically install LSPs to stdpath for neovim
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',

            'j-hui/fidget.nvim',

            -- Additional LuaLS configuration for editing Neovim config
            {
                'folke/lazydev.nvim',
                ft = 'lua', -- only load on lua files
                opts = {},
            },
        },
    },

    -- Improved C# LSP support
    { 'Hoffs/omnisharp-extended-lsp.nvim', lazy = true },
}

---------- CONFIGURE LSP ----------
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(client, bufnr)
    -- Helper function to more easily define LSP related mappings
    local nmap = function(keys, func, desc)
        if desc then
            desc = 'LSP: ' .. desc
        end

        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end

    -- Client-specific mappings
    if client.name == 'omnisharp' then
        nmap('gd', require('omnisharp_extended').lsp_definition, '[G]oto [D]efinition')
        nmap('gI', require('omnisharp_extended').lsp_implementation, '[Goto] [I]mplementation')
        nmap('<leader>D', require('omnisharp_extended').lsp_type_definition, 'Type [D]efinition')
    end

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })
end

---------- CONFIGURE MASON ----------
-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

-- Enable the following language servers
local servers = {
    html = { filetypes = { 'html', 'twig', 'hbs' } },
    lua_ls = {
        settings = {
            Lua = {
                runtime = {
                    version = 'Lua 5.1',
                },
                -- telemetry = { enable = false },
                workspace = {
                    library = {
                        '$VIMRUNTIME/lua/vim',
                        '${3rd}/luv/library',
                    },
                },
                completion = {
                    callSnippet = 'Replace',
                },
            },
        },
    },
    lemminx = {
        filetypes = { 'xml', 'config' },
    },
    ts_ls = {},
    omnisharp = {
        filetypes = { 'cs', 'vb' },
        settings = {
            FormattingOptions = {
                -- Enables support for reading code style, naming convention and analyzer
                -- settings from .editorconfig.
                EnableEditorConfigSupport = true,
                -- Specifies whether 'using' directives should be grouped and sorted during
                -- document formatting.
                OrganizeImports = true,
            },
            RoslynExtensionsOptions = {
                -- Enables support for roslyn analyzers, code fixes and rulesets.
                EnableAnalyzersSupport = true,
                -- Enables support for showing unimported types and unimported extension
                -- methods in completion lists. When committed, the appropriate using
                -- directive will be added at the top of the current file. This option can
                -- have a negative impact on initial completion responsiveness,
                -- particularly for the first few completion sessions after opening a
                -- solution.
                EnableImportCompletion = true,
                -- Only run analyzers against open files when 'enableRoslynAnalyzers' is
                -- true
                AnalyzeOpenDocumentsOnly = nil,
            },
        },
    },
}

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
-- Plugins that need to modify capabilities can do so here
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require('mason-lspconfig')
mason_lspconfig.setup({
    ensure_installed = vim.tbl_keys(servers),
})
mason_lspconfig.setup_handlers({
    function(server_name)
        require('lspconfig')[server_name].setup({
            capabilities = capabilities,
            on_attach = on_attach,
            settings = (servers[server_name] or {}).settings,
            filetypes = (servers[server_name] or {}).filetypes,
            handlers = (servers[server_name] or {}).handlers,
        })
    end,
})

-- vim: ts=2 sts=2 sw=2 et

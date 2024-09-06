require('config.options')

require('config.lazy-setup')

require('config.lsp-setup')

require('config.cmp-setup')

require('config.autocmd')

require('config.commands')

require('config.keymaps')

-- Enable colorscheme
vim.cmd([[colorscheme nightfly]])
vim.g.nightflyNormalFloat = true
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = 'single',
})
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signatureHelp, {
    border = 'single',
})
vim.diagnostic.config({ float = { border = 'single' } })

--
-- vim: ts=2 sts=2 sw=2 et

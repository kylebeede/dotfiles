---------- CONFIGURE NVIM-CMP ----------
-- See `:help cmp`

local cmp = require('cmp')
local winhighlight = {
    winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel',
}
-- local defaults = require('cmp.config.default')()

cmp.setup({
    sources = cmp.config.sources({
        { name = 'nvim_lsp', group_index = 1 },
        { name = 'path', group_index = 1 },
        { name = 'copilot', group_index = 1 },
        -- { name = 'luasnip' },
        { name = 'buffer', group_index = 2 },
        {
            name = 'lazydev',
            group_index = 0, -- set group index to 0 to skip loading LuaLS completions
        },
    }),
    mapping = cmp.mapping.preset.insert({
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-l>'] = cmp.mapping.complete({}),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ['<S-CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ['<C-CR>'] = function(fallback)
            cmp.abort()
            fallback()
        end,
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            -- elseif luasnip.expand_or_locally_jumpable() then
            --   luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            -- elseif luasnip.locally_jumpable(-1) then
            --   luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    }),
    window = {
        completion = cmp.config.window.bordered(winhighlight),
        documentation = cmp.config.window.bordered(winhighlight),
    },
})

-- vim: ts=2 sts=2 sw=2 et

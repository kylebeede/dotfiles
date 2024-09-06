local function split(inputstr, sep)
    if sep == nil then
        sep = '%s'
    end
    local t = {}
    for str in string.gmatch(inputstr, '([^' .. sep .. ']+)') do
        table.insert(t, str)
    end
    return t
end

return {
    -- Autocompletion
    {
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
        dependencies = {
            -- Adds LSP completion capabilities
            'hrsh7th/cmp-nvim-lsp',

            -- Adds a number of user-friendly snippets
            -- 'rafamadriz/friendly-snippets',
        },
    },

    {
        'RRethy/vim-illuminate',
        event = { 'BufReadPre', 'BufNewFile' },
        opts = {
            delay = 350,
            under_cursor = false,
            min_count_to_highlight = 1,
            large_file_cutoff = 2000, -- lines
            large_file_overrides = {
                providers = {
                    'lsp', -- still allow lsp to provide references for large files
                },
            },
            filetypes_denylist = {
                'alpha',
                'dirbuf',
                'dirvish',
                'fugitive',
                'mason',
                'lazy',
                'help',
                'checkhealth',
            },
            modes_denylist = { 'v', '\22' },
        },
        config = function(_, opts)
            require('illuminate').configure(opts)

            local function map(key, dir, buffer)
                vim.keymap.set('n', key, function()
                    require('illuminate')['goto_' .. dir .. '_reference'](false)
                end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. ' Reference', buffer = buffer })
            end

            map(']]', 'next')
            map('[[', 'prev')

            -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
            vim.api.nvim_create_autocmd('FileType', {
                callback = function()
                    local buffer = vim.api.nvim_get_current_buf()
                    map(']]', 'next', buffer)
                    map('[[', 'prev', buffer)
                end,
            })

            vim.api.nvim_set_hl(0, 'IlluminatedWordText', { link = 'Visual' })
            vim.api.nvim_set_hl(0, 'IlluminatedWordRead', { link = 'Visual' })
            vim.api.nvim_set_hl(0, 'IlluminatedWordWrite', { link = 'Visual' })
        end,
        keys = {
            { ']]', desc = 'Next Reference' },
            { '[[', desc = 'Prev Reference' },
        },
    },

    {
        'kylechui/nvim-surround',
        version = '*', -- Use for stability; omit to use `main` branch for the latest features
        event = 'VeryLazy',
        config = function()
            require('nvim-surround').setup({
                -- Configuration here, or leave empty to use defaults
            })
        end,
    },

    {
        'windwp/nvim-autopairs',
        event = 'InsertEnter',
        config = function()
            local npairs = require('nvim-autopairs')
            local Rule = require('nvim-autopairs.rule')
            local cond = require('nvim-autopairs.conds')

            npairs.setup({})

            npairs.add_rules({
                Rule('<[a-zA-Z]*>$', '', { 'react', 'typescriptreact' })
                    :use_regex(true)
                    -- :with_pair(cond.not_after_regex("("))
                    :replace_endpair(function(opts)
                        print(vim.inspect(opts))
                        local prev_char_split = split(opts.prev_char, '<')
                        print(vim.inspect(prev_char_split))
                        return '</' .. prev_char_split[2]
                    end),
            })
        end,
    },

    {
        'folke/lazydev.nvim',
        ft = 'lua', -- only load on lua files
        opts = {
            library = {
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
                { path = 'luvit-meta/library', words = { 'vim%.uv' } },
            },
        },
    },
    { 'Bilal2453/luvit-meta', lazy = true }, -- optional `vim.uv` typings
}

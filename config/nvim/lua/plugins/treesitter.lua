return {
    {
        'nvim-treesitter/nvim-treesitter',
        dependencies = {
            -- 'nvim-treesitter/nvim-treesitter-context',
            'nvim-treesitter/nvim-treesitter-textobjects',
        },
        version = false,
        build = ':TSUpdate',
        event = { 'BufReadPost', 'BufNewFile' },
        opts = function()
            require('nvim-treesitter.configs').setup({
                modules = {},
                sync_install = false,
                ignore_install = {},
                auto_install = true,
                autotag = {
                    enable = true,
                },
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                    disable = { 'log' },
                },
                indent = {
                    enable = true,
                    disable = { 'log' },
                },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = '<C-space>',
                        node_incremental = '<C-space>',
                        scope_incremental = false,
                        node_decremental = '<bs>',
                    },
                    disable = { 'log' },
                },
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                        keymaps = {
                            -- You can use the capture groups defined in textobjects.scm
                            ['aa'] = '@parameter.outer',
                            ['ia'] = '@parameter.inner',
                            ['af'] = '@function.outer',
                            ['if'] = '@function.inner',
                            ['ac'] = '@class.outer',
                            ['ic'] = '@class.inner',
                        },
                    },
                    move = {
                        enable = true,
                        set_jumps = true, -- whether to set jumps in the jumplist
                        goto_next_start = {
                            [']m'] = '@function.outer',
                            [']]'] = '@class.outer',
                        },
                        goto_next_end = {
                            [']M'] = '@function.outer',
                            [']['] = '@class.outer',
                        },
                        goto_previous_start = {
                            ['[m'] = '@function.outer',
                            ['[['] = '@class.outer',
                        },
                        goto_previous_end = {
                            ['[M'] = '@function.outer',
                            ['[]'] = '@class.outer',
                        },
                        disable = { 'log' },
                    },
                    swap = {
                        enable = true,
                        swap_next = {
                            ['<leader>cmp'] = '@parameter.inner',
                        },
                        swap_previous = {
                            ['<leader>cmP'] = '@parameter.inner',
                        },
                        disable = { 'log' },
                    },
                },
                ---@diagnostic disable-next-line: unused-local
                disable = function(lang, buf)
                    local max_filesize = 500 * 1024 -- 500 KB
                    ---@diagnostic disable-next-line: undefined-field
                    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                    if ok and stats and stats.size > max_filesize then
                        return true
                    end
                end,

                ensure_installed = {
                    'bash',
                    'c',
                    'c_sharp',
                    'cpp',
                    'css',
                    'diff',
                    'go',
                    'javascript',
                    'json',
                    'lua',
                    'markdown',
                    'markdown_inline',
                    'python',
                    'regex',
                    'rust',
                    'tsx',
                    'typescript',
                    'vim',
                    'vimdoc',
                    'xml',
                    'yaml',
                },
            })
        end,
    },

    -- 	{
    -- 		'nvim-treesitter/nvim-treesitter-context',
    -- 		opts = {
    -- 			enable = false,     -- Enable this plugin (Can be enabled/disabled later via commands)
    -- 			max_lines = 0,      -- How many lines the window should span. Values <= 0 mean no limit.
    -- 			min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
    -- 			line_numbers = true,
    -- 			multiline_threshold = 20, -- Maximum number of lines to show for a single context
    -- 			trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
    -- 			mode = 'cursor',    -- Line used to calculate context. Choices: 'cursor', 'topline'
    -- 			-- Separator between context and content. Should be a single character string, like '-'.
    -- 			-- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
    -- 			separator = nil,
    -- 			zindex = 20, -- The Z-index of the context window
    -- 			indent = {
    -- 				enable = true,
    -- 			},
    -- 			on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
    -- 		},
    -- 	},
}

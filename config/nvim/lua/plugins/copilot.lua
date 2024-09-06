return {
    {
        'zbirenbaum/copilot.lua',
        enabled = true,
        cmd = 'Copilot',
        build = ':Copilot auth',
        event = 'InsertEnter',
        config = function()
            require('copilot').setup({
                panel = {
                    enabled = false,
                    -- auto_refresh = false,
                    -- keymap = {
                    --   jump_prev = "[[",
                    --   jump_next = "]]",
                    --   accept = "<CR>",
                    --   refresh = "gr",
                    --   open = "<M-CR>"
                    -- },
                    -- layout = {
                    --   position = "bottom", -- | top | left | right
                    --   ratio = 0.4
                    -- },
                },
                suggestion = {
                    enabled = false,
                    -- auto_trigger = false,
                    -- debounce = 75,
                    -- keymap = {
                    --   accept = "<M-l>",
                    --   accept_word = false,
                    --   accept_line = false,
                    --   next = "<M-]>",
                    --   prev = "<M-[>",
                    --   dismiss = "<C-]>",
                    -- },
                },
                filetypes = {
                    yaml = false,
                    markdown = false,
                    help = false,
                    gitcommit = false,
                    gitrebase = false,
                    hgcommit = false,
                    svn = false,
                    cvs = false,
                    ['.'] = false,
                },
                copilot_node_command = 'node', -- Node.js version must be > 18.x
                server_opts_overrides = {},
            })
        end,
    },
    {
        'zbirenbaum/copilot-cmp',
        event = 'InsertEnter',
        config = function()
            require('copilot_cmp').setup()
        end,
    },
    {
        'CopilotC-Nvim/CopilotChat.nvim',
        opts = {
            show_help = 'yes', -- Show help text for CopilotChatInPlace, default: yes
            debug = false, -- Enable or disable debug mode, the log file will be in ~/.local/state/nvim/CopilotChat.nvim.log
            disable_extra_info = 'no', -- Disable extra information (e.g: system prompt) in the response.
            language = 'English', -- Copilot answer language settings when using default prompts. Default language is English.
            -- proxy = "socks5://127.0.0.1:3000", -- Proxies requests via https or socks.
            -- temperature = 0.1,
            prompts = {
                -- Code related prompts
                Explain = 'Please explain how the following code works.',
                Review = 'Please review the following code and provide suggestions for improvement.',
                Tests = 'Please explain how the selected code works, then generate unit tests for it.',
                Refactor = 'Please refactor the following code to improve its clarity and readability.',
                FixCode = 'Please fix the following code to make it work as intended.',
                FixError = 'Please explain the error in the following text and provide a solution.',
                BetterNamings = 'Please provide better names for the following variables and functions.',
                Documentation = 'Please provide documentation for the following code.',
                SwaggerApiDocs = 'Please provide documentation for the following API using Swagger.',
                SwaggerJsDocs = 'Please write JSDoc for the following API using Swagger.',
                -- Text related prompts
                Summarize = 'Please summarize the following text.',
                Spelling = 'Please correct any grammar and spelling errors in the following text.',
                Wording = 'Please improve the grammar and wording of the following text.',
                Concise = 'Please rewrite the following text to make it more concise.',
            },
        },
        build = function()
            vim.notify("Please update the remote plugins by running ':UpdateRemotePlugins', then restart Neovim.")
        end,
        -- event = 'VeryLazy',
        cmd = {
            'CopilotChatExplain',
            'CopilotChatTests',
            'CopilotChatReview',
            'CopilotChatRefactor',
            'CopilotChatBetterNamings',
            'CopilotChatVisual',
            'CopilotChatInline',
            'CopilotChatCommit',
            'CopilotChatCommitStaged',
            'CopilotChatDebugInfo',
            'CopilotChatFixDiagnostic',
            'CopilotChatReset',
            'CopilotChatToggle',
            'CopilotChatModels',
            'CopilotChat ',
            'CopilotChatBuffer',
        },
        keys = {
            -- See whichkey configuration
        },
        config = function(_, opts)
            local chat = require('CopilotChat')
            local select = require('CopilotChat.select')
            -- Use unnamed register for the selection
            opts.selection = select.unnamed

            -- Override the git prompts message
            opts.prompts.Commit = {
                prompt = 'Write commit message for the change with commitizen convention',
                selection = select.gitdiff,
            }
            opts.prompts.CommitStaged = {
                prompt = 'Write commit message for the change with commitizen convention',
                selection = function(source)
                    return select.gitdiff(source, true)
                end,
            }

            chat.setup(opts)
            -- Setup the CMP integration
            require('CopilotChat.integrations.cmp').setup()

            vim.api.nvim_create_user_command('CopilotChatVisual', function(args)
                chat.ask(args.args, { selection = select.visual })
            end, { nargs = '*', range = true })

            -- Inline chat with Copilot
            vim.api.nvim_create_user_command('CopilotChatInline', function(args)
                chat.ask(args.args, {
                    selection = select.visual,
                    window = {
                        layout = 'float',
                        relative = 'cursor',
                        width = 1,
                        height = 0.4,
                        row = 1,
                    },
                })
            end, { nargs = '*', range = true })

            -- Restore CopilotChatBuffer
            vim.api.nvim_create_user_command('CopilotChatBuffer', function(args)
                chat.ask(args.args, { selection = select.buffer })
            end, { nargs = '*', range = true })

            -- Custom buffer for CopilotChat
            vim.api.nvim_create_autocmd('BufEnter', {
                pattern = 'copilot-*',
                callback = function()
                    vim.opt_local.relativenumber = true
                    vim.opt_local.number = true

                    -- Get current filetype and set it to markdown if the current filetype is copilot-chat
                    -- local ft = vim.bo.filetype
                    -- if ft == 'copilot-chat' then
                    --   vim.bo.filetype = 'markdown'
                    -- end
                end,
            })
        end,
    },
}

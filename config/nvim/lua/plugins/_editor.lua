return {
    -- enhanced search
    {
        'folke/flash.nvim',
        event = 'BufEnter',
        ---@type Flash.Config
        opts = {},
		-- stylua: ignore
		keys = {
			-- { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
			{ "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
			{ "r",     mode = { "o" },           function() require("flash").remote() end,            desc = "Remote Flash" },
			{ "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
			{ "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
		},
    },

    -- Adds git related signs to the gutter,
    -- as well as utilities for managing changes
    {
        'lewis6991/gitsigns.nvim',
        event = 'VeryLazy',
        opts = {
            -- See `:help gitsigns.txt`
            signs = {
                add = { text = '+' },
                change = { text = '~' },
                delete = { text = '_' },
                topdelete = { text = '‾' },
                changedelete = { text = '~' },
            },
            on_attach = function(bufnr)
                -- don't override the built-in and fugitive keymaps
                local gs = package.loaded.gitsigns
                vim.keymap.set({ 'n', 'v' }, ']c', function()
                    if vim.wo.diff then
                        return ']c'
                    end
                    vim.schedule(function()
                        gs.next_hunk()
                    end)
                    return '<Ignore>'
                end, { expr = true, buffer = bufnr, desc = 'Jump to next hunk' })
                vim.keymap.set({ 'n', 'v' }, '[c', function()
                    if vim.wo.diff then
                        return '[c'
                    end
                    vim.schedule(function()
                        gs.prev_hunk()
                    end)
                    return '<Ignore>'
                end, { expr = true, buffer = bufnr, desc = 'Jump to previous hunk' })
            end,
        },
    },

    -- better diagnostics list and others
    {
        'folke/trouble.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        cmd = 'Trouble',
        opts = {
            modes = {
                diagnostics_buffer = {
                    mode = 'diagnostics', -- inherit from diagnostics mode
                    filter = { buf = 0 }, -- filter diagnostics to the current buffer
                },
            },
        },
    },

    -- visual key binds
    { 'folke/which-key.nvim', opts = {}, event = 'VeryLazy' },

    -- test framework
    {
        'nvim-neotest/neotest',
        event = 'VeryLazy',
        dependencies = {
            'nvim-neotest/nvim-nio',
            'nvim-lua/plenary.nvim',
            'antoinemadec/FixCursorHold.nvim',
            'nvim-treesitter/nvim-treesitter',
            'Issafalcon/neotest-dotnet',
            'haydenmeade/neotest-jest',
        },
        -- config = function()
        -- 	require('neotest').setup {
        -- 		adapters = {
        -- 			require 'neotest-dotnet' {
        -- 				dap = { justMyCode = false },
        -- 			},
        -- 			-- require 'neotest-jest' {
        -- 			-- 	jestCommand = 'npm test --',
        -- 			-- 	jestConfigFile = function(file)
        -- 			-- 		if string.find(file, '/tests/') then
        -- 			-- 			return string.match(file, '(.-/)tests') .. 'jest.config.ts'
        -- 			-- 		end
        -- 			--
        -- 			-- 		return vim.fn.getcwd() .. '/jest.config.ts'
        -- 			-- 	end,
        -- 			-- 	env = { NODE_ENV = 'test' },
        -- 			-- 	cwd = function()
        -- 			-- 		return vim.fn.getcwd()
        -- 			-- 	end,
        -- 			-- },
        -- 		},
        -- 	}
        -- end,
    },

    -- DAP client
    {
        'mfussenegger/nvim-dap',
        dependencies = {
            -- Creates a beautiful debugger UI
            'rcarriga/nvim-dap-ui',

            -- Package manager
            'williamboman/mason.nvim',
            'jay-babu/mason-nvim-dap.nvim',
        },
        config = function(_, opts)
            local dap = require('dap')
            local dapui = require('dapui')

            require('mason-nvim-dap').setup({
                -- Makes a best effort to setup the various debuggers with
                -- reasonable debug configurations
                automatic_setup = true,

                -- You can provide additional configuration to the handlers,
                -- see mason-nvim-dap README for more information
                handlers = {},

                ensure_installed = { 'js', 'netcoredbg' },
            })

            -- Dap UI setup
            -- For more information, see |:help nvim-dap-ui|
            dapui.setup({
                -- Set icons to characters that are more likely to work in every terminal.
                --    Feel free to remove or use ones that you like more! :)
                --    Don't feel like these are good choices.
                icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
                controls = {
                    icons = {
                        pause = '⏸',
                        play = '▶',
                        step_into = '⏎',
                        step_over = '⏭',
                        step_out = '⏮',
                        step_back = 'b',
                        run_last = '▶▶',
                        terminate = '⏹',
                        disconnect = '⏏',
                    },
                },
            })

            -- Dap adapter setup
            dap.adapters.netcoredbg = {
                type = 'executable',
                command = '/usr/local/netcoredbg',
                args = { '--interpreter=vscode' },
            }

            -- Dap configuration setup
            dap.configurations.cs = {
                -- Used with test runner
                {
                    type = 'netcoredbg',
                    name = 'netcoredbg',
                    request = 'attach',
                },
                -- Used to attach to process
                {
                    type = 'netcoredbg',
                    name = 'netcoredbg - pick',
                    request = 'attach',
                    processId = function()
                        return require('dap.utils').pick_process({ filter = 'Faithlife' })
                    end,
                },
            }

            dap.listeners.after.event_initialized['dapui_config'] = dapui.open
            dap.listeners.before.event_terminated['dapui_config'] = dapui.close
            dap.listeners.before.event_exited['dapui_config'] = dapui.close
        end,
    },

    -- {
    -- 	'MoaidHathot/dotnet.nvim',
    -- 	cmd = 'DotnetUI',
    -- 	opts = {},
    -- },
}

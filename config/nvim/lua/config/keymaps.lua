local icons = require('icons')

local function is_directory(path)
    local stat = vim.loop.fs_stat(path)
    return stat and stat.type == 'directory'
end

local function toggle_virtual_text()
    ---@diagnostic disable-next-line: undefined-field
    local current_value = vim.diagnostic.config().virtual_text
    vim.diagnostic.config({
        virtual_text = not current_value,
    })
    if current_value then
        print('Virtual text disabled')
    else
        print('Virtual text enabled')
    end
end

local original_cwd = vim.fn.getcwd()
local function open_custom_filepicker()
    local telescopeBuiltins = require('telescope.builtin')
    telescopeBuiltins.find_files({ cwd = original_cwd })
end

local function open_custom_grep()
    local telescopeBuiltins = require('telescope.builtin')
    telescopeBuiltins.live_grep({ cwd = original_cwd })
end

local function fzf_filepicker()
    local fzf = require('fzf-lua')

    local input = vim.fn.input('Enter search directory: ')
    if input ~= '' then
        fzf.files({ cwd = input })
    end
end

local function set_conditional_breakpoint()
    require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
end

local function toggle_colorcolumn()
    if vim.wo.colorcolumn ~= '' then
        vim.wo.colorcolumn = ''
    else
        local input = vim.fn.input('Enter colorcolumn value: ')
        if input ~= '' then
            vim.wo.colorcolumn = input
        else
            vim.wo.colorcolumn = ''
        end
    end
end

local function toggle_statusline()
    if vim.o.laststatus == 0 then
        vim.o.laststatus = 2
    else
        vim.o.laststatus = 0
    end
end

-- Global variable to store the path to the worktree
_G.current_worktree_path = nil

-- Remove the worktree if it exists
local function clear_worktree(logMessages)
    if _G.current_worktree_path and is_directory(_G.current_worktree_path) then
        local remove_command = string.format('git worktree remove %s', _G.current_worktree_path)
        vim.fn.system(remove_command)

        -- Check if the remove command was successful
        if vim.v.shell_error == 0 and logMessages then
            -- For some reason, the dir can still exist here. Make sure it's deleted
            vim.fn.system('rm -rf ' .. _G.current_worktree_path)

            if vim.v.shell_error == 0 and logMessages then
                print(string.format('Successfully removed worktree at %s', _G.current_worktree_path))
            end
        else
            if logMessages then
                print(string.format('Failed to remove worktree at %s', _G.current_worktree_path))
            end
        end

        -- Clear the global variable
        _G.current_worktree_path = nil
    else
        if logMessages then
            print('No worktree to remove')
        end
    end
end

-- TODO: exclude *.g.cs files
local function fetch_and_diffview(remote, branch)
    -- Diffview is lazy loaded, so we need to require it here
    require('diffview')

    -- Fetch the latest origin/master
    vim.fn.system('git fetch origin master')

    -- Check if the fetch command was successful
    if vim.v.shell_error == 0 then
        -- If remote and branch are provided, fetch them
        if remote and branch then
            local fetch_command = string.format('git fetch %s %s', remote, branch)
            vim.fn.system(fetch_command)

            -- Check if the fetch command was successful
            if vim.v.shell_error == 0 then
                local home_dir = os.getenv('HOME')
                local worktree_name = string.format('%s_%s', remote, branch)
                local worktree_path = string.format('%s/Code/worktrees/%s', home_dir, worktree_name)

                -- Check if worktree dir exists
                -- This can happen if nvim is closed without quitting review first
                if _G.current_worktree_path == nil and is_directory(worktree_path) then
                    _G.current_worktree_path = worktree_path
                end

                -- Remove worktree if it exists
                clear_worktree(false)

                -- Create a new worktree
                local worktree_command = string.format('git worktree add %s %s/%s', worktree_path, remote, branch)
                vim.fn.system(worktree_command)

                -- Check if the worktree command was successful
                if vim.v.shell_error == 0 then
                    -- Store the worktree path in the global variable
                    _G.current_worktree_path = worktree_path

                    -- Run the DiffviewOpen command with the specified remote and branch
                    local diffview_command = string.format('DiffviewOpen -C%s origin/master...HEAD --imply-local', worktree_path)
                    vim.cmd(diffview_command)
                else
                    -- Print an error message if the worktree creation failed
                    print(string.format('Failed to create worktree at %s', worktree_path))
                end
            else
                -- Print an error message if the fetch failed
                print(string.format('Failed to fetch from %s %s', remote, branch))
            end
        else
            -- Run the DiffviewOpen command against HEAD if no remote/branch is provided
            vim.cmd('DiffviewOpen origin/master...HEAD --imply-local')
        end
    else
        -- Print an error message if the fetch failed
        print('Failed to fetch from origin master')
    end
end

-- Prompts for remote/branch before calling fetch_and_diffview
local function prompt_and_fetch_and_diffview()
    vim.ui.input({ prompt = 'Enter remote:branch (e.g., upstream:develop): ' }, function(input)
        if input then
            local remote, branch = input:match('([^/]+):([^/]+)')
            fetch_and_diffview(remote, branch)
        end
    end)
end

-- Function to close the review and remove the worktree
local function close_review()
    -- TODO: If review is closed very soon after opening this errors: `client omnisharp quit with exit code 0 and signal 6`
    vim.cmd('DiffviewClose')
    clear_worktree(true)
end

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- ── Remap for dealing with word wrap ────────────────────────────────
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

--                                  ╭─────────╮
--                                  │ Windows │
--                                  ╰─────────╯
-- ── Panel movement ──────────────────────────────────────────────────
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Focus panel to the left' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Focus panel to the right' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Focus panel below' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Focus panel above' })
-- ── Window resizing ─────────────────────────────────────────────────
vim.keymap.set('n', '+', '<cmd>vert res +5<cr>', { desc = 'Increase window width 5' })
vim.keymap.set('n', '-', '<cmd>vert res -5<cr>', { desc = 'Decrease window width 5' })
vim.keymap.set('n', '<Up>', '<cmd>horizontal res +5<cr>', { desc = 'Increase window height 5' })
vim.keymap.set('n', '<Down>', '<cmd>horizontal res -5<cr>', { desc = 'Decrease window height 5' })

--                                   ╭──────╮
--                                   │ Goto │
--                                   ╰──────╯
vim.keymap.set('n', 'gd', require('telescope.builtin').lsp_definitions, { desc = '[G]oto [D]efinition' })
vim.keymap.set('n', 'gr', function()
    local telescopeBuiltins = require('telescope.builtin')
    telescopeBuiltins.lsp_references()
end, { desc = '[G]oto [R]eferences' })
vim.keymap.set('n', 'gI', require('telescope.builtin').lsp_implementations, { desc = '[G]oto [I]mplementation' })
vim.keymap.set('n', '<leader>ds', require('telescope.builtin').lsp_document_symbols, { desc = '[D]ocument [S]ymbols' })

-- ── See `:help K` for why this keymap ───────────────────────────────
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover Documentation' })
vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, { desc = 'Signature Documentation' })

-- ── Lesser used LSP functionality ───────────────────────────────────
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = '[G]oto [D]eclaration' })

require('which-key').add({
    --                                   ╭──────╮
    --                                   │ Root │
    --                                   ╰──────╯
    {
        '<leader>l',
        '<cmd>Lazy<cr>',
        desc = 'Lazy - plugin manager',
        icon = icons.misc.Package,
    },
    {
        '<leader>m',
        '<cmd>Mason<cr>',
        desc = 'Mason - package manager',
        icon = icons.misc.Package,
    },
    {
        '<leader>e',
        '<cmd>NvimTreeToggle<cr>',
        desc = 'File [E]xplorer',
        icon = icons.kind.Folder,
    },
    {
        '<leader>/',
        '<cmd>lua require("flash").jump()<cr>',
        desc = 'Flash',
        icon = icons.ui.Search,
    },

    --                                    ╭────╮
    --                                    │ AI │
    --                                    ╰────╯
    -- The mappings are done in the Copilot Chat plugin configuration
    { '<leader>a', group = '[A]I', icon = icons.misc.Robot },
    { '<leader>ae', '<cmd>CopilotChatExplain @buffer<cr>', desc = 'CopilotChat - Explain code' },
    { '<leader>at', '<cmd>CopilotChatTests<cr>', desc = 'CopilotChat - Generate tests' },
    { '<leader>ar', '<cmd>CopilotChatReview<cr>', desc = 'CopilotChat - Review code' },
    { '<leader>aR', '<cmd>CopilotChatRefactor<cr>', desc = 'CopilotChat - Refactor code' },
    { '<leader>an', '<cmd>CopilotChatBetterNamings<cr>', desc = 'CopilotChat - Better Naming' },
    { '<leader>ab', '<cmd>CopilotChatBuffer<cr>', desc = 'CopilotChat - Explain buffer' },
    -- Chat with Copilot in visual mode
    { '<leader>av', ':CopilotChatVisual', desc = 'CopilotChat - Open in vertical split', mode = 'x' },
    { '<leader>ax', ':CopilotChatInline<cr>', desc = 'CopilotChat - Inline chat', mode = 'x' },
    -- Generate commit message based on the git diff
    { '<leader>am', '<cmd>CopilotChatCommit<cr>', desc = 'CopilotChat - Generate commit message for all changes' },
    { '<leader>aM', '<cmd>CopilotChatCommitStaged<cr>', desc = 'CopilotChat - Generate commit message for staged changes' },
    -- Debug
    { '<leader>ad', '<cmd>CopilotChatDebugInfo<cr>', desc = 'CopilotChat - Debug Info' },
    -- Fix the issue with diagnostic
    { '<leader>af', '<cmd>CopilotChatFixDiagnostic<cr>', desc = 'CopilotChat - Fix Diagnostic' },
    -- Clear buffer and chat history
    { '<leader>al', '<cmd>CopilotChatReset<cr>', desc = 'CopilotChat - Clear buffer and chat history' },
    -- Toggle Copilot Chat Vsplit
    { '<leader>av', '<cmd>CopilotChatToggle<cr>', desc = 'CopilotChat - Toggle' },
    -- Copilot Chat Models
    { '<leader>a?', '<cmd>CopilotChatModels<cr>', desc = 'CopilotChat - Select Models' },
    -- Custom input for CopilotChat
    {
        '<leader>ai',
        function()
            local input = vim.fn.input('Ask Copilot: ')
            if input ~= '' then
                vim.cmd('CopilotChat ' .. input)
            end
        end,
        desc = 'CopilotChat - Ask input',
    },
    -- Quick chat with Copilot
    {
        '<leader>aq',
        function()
            local input = vim.fn.input('Quick Chat: ')
            if input ~= '' then
                vim.cmd('CopilotChatBuffer ' .. input)
            end
        end,
        desc = 'CopilotChat - Quick chat',
    },

    --                                   ╭──────╮
    --                                   │ Code │
    --                                   ╰──────╯
    { '<leader>c', group = '[C]ode', icon = icons.ui.Code },
    { '<leader>cF', '<Cmd>AutoFormatToggle<CR>', desc = 'Toggle Auto [F]ormat' },
    -- ── Boxes ───────────────────────────────────────────────────────────
    { '<leader>cb', group = '[B]oxes' },
    { '<leader>cbb', '<Cmd>CBcabox<CR>', desc = '[B]ox Title' },
    { '<leader>cbt', '<Cmd>CBllline<CR>', desc = '[T]itled Line' },
    -- ── /Boxes ───────────────────────────────────────────────────────────
    { '<leader>ca', vim.lsp.buf.code_action, desc = '[C]ode [A]ction' },
    { '<leader>cr', vim.lsp.buf.rename, desc = '[R]ename' },
    { '<leader>cD', "<Cmd>require('telescope.builtin').lsp_type_definitions<cr>", desc = 'Type [D]efinition' },
    { '<leader>cs', '<Cmd>Trouble symbols toggle focus=false<cr>', desc = '[S]ymbols (Trouble)' },
    { '<leader>co', '<Cmd>Trouble lsp toggle focus=false win.position=right<cr>', desc = 'LSP Definitions / references / ... (Trouble)' },
    { '<leader>cm', group = '[M]ove parameter', icon = icons.ui.BoldArrowRight },
    -- These mappings are done in the treesitter configuration

    --                                ╭─────────────╮
    --                                │ Diagnostics │
    --                                ╰─────────────╯
    { '<leader>x', group = 'Diagnostics', icon = { icon = icons.diagnostics.Error, color = 'orange' } },
    { '<leader>xt', '<cmd>Trouble diagnostics toggle<CR>', desc = '[T]oggle diagnostics (Trouble)' },
    { '<leader>xb', '<cmd>Trouble diagnostics_buffer toggle<CR>', desc = '[B]uffer diagnostics (Trouble)' },
    { '<leader>xl', '<cmd>Trouble loclist toggle<CR>', desc = '[L]ocation List (Trouble)' },
    { '<leader>xq', '<cmd>Trouble qflist toggle<CR>', desc = '[Q]uickfix List (Trouble)' },
    {
        '[d',
        function()
            require('trouble').previous({ skip_groups = true, jump = true })
        end,
        desc = 'Go to previous diagnostic message',
    },
    {
        ']d',
        function()
            require('trouble').next({ not_exist = true, skip_groups = true, jump = true })
        end,
        desc = 'Go to next diagnostic message',
    },

    --                                    ╭─────╮
    --                                    │ Git │
    --                                    ╰─────╯
    { '<leader>g', group = '[G]it', icon = icons.git.Octoface },
    { '<leader>gp', '<cmd>Gitsigns preview_hunk_inline<cr>', desc = '[P]review git hunk' },
    { '<leader>gb', '<cmd>Git blame<cr>', desc = '[B]lame' },
    { '<leader>gc', '<cmd>Telescope git_commits<cr>', desc = '[C]ommits' },
    { '<leader>gs', '<cmd>Telescope git_status<cr>', desc = '[S]tatus' },
    { '<leader>gf', '<cmd>G<cr>', desc = '[F]ugitive' },
    { '<leader>gd', fetch_and_diffview, desc = '[D]iff current changes' },
    { '<leader>gr', prompt_and_fetch_and_diffview, desc = '[R]eview remote/branch' },
    { '<leader>gR', close_review, desc = 'Quit [r]eviewing' },
    { '<leader>gl', '<cmd>GBrowse<cr>', desc = '[L]ink to github' }, -- TODO fix
    { '<leader>g_', hidden = true },

    --                                  ╭────────╮
    --                                  │ Search │
    --                                  ╰────────╯
    { '<leader>s', group = '[S]earch', icon = icons.ui.Search },
    { '<leader>s_', hidden = true },
    { '<leader>so', '<Cmd>Telescope oldfiles<Cr>', desc = 'Search [O]ldfiles' },
    { '<leader>sb', '<Cmd>Telescope buffers<Cr>', desc = 'Search [B]uffers' },
    { '<leader>sf', open_custom_filepicker, desc = 'Search [F]iles' },
    { '<leader>sF', fzf_filepicker, desc = 'Search [F]iles in dir' },
    { '<leader>sh', '<Cmd>Telescope help_tags<Cr>', desc = 'Search [H]elp' },
    { '<leader>sw', '<Cmd>Telescope grep_string<Cr>', desc = '[S]earch current [W]ord' },
    { '<leader>sg', open_custom_grep, desc = '[S]earch by [G]rep' },
    { '<leader>sd', '<Cmd>Telescope diagnostics<Cr>', desc = '[S]earch [D]iagnostics' },
    { '<leader>sr', '<Cmd>Telescope resume<Cr>', desc = '[S]earch [R]esume' },
    { '<leader>sj', '<Cmd>Telescope jumplist<Cr>', desc = '[S]earch [J]umplist' },
    { '<leader>sG', '<Cmd>Telescope git_files<Cr>', desc = '[S]earch [G]it files' },
    { '<leader>sz', '<cmd>Telescope spell_suggest<cr>', desc = 'Spelling suggestions' },
    { '<leader>sk', '<cmd>Telescope keymaps<cr>', desc = '[S]earch [K]eymaps' },
    {
        '<leader>sc',
        "<Cmd>lua require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false })<CR>",
        desc = 'Search [C]urrent Buffer',
    },

    --                                 ╭───────────╮
    --                                 │ Workspace │
    --                                 ╰───────────╯
    { '<leader>w', group = '[W]orkspace', icon = icons.ui.Project },
    { '<leader>wa', '<Cmd>vim.lsp.buf.add_workspace_folder<Cr>', desc = '[W]orkspace [A]dd Folder' },
    { '<leader>wr', '<Cmd>vim.lsp.buf.remove_workspace_folder<Cr>', desc = '[W]orkspace [R]emove Folder' },
    {
        '<leader>wl',
        function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end,
        desc = '[W]orkspace [L]ist Folders',
    },
    { '<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, desc = '[W]orkspace [S]ymbols' },
    { '<leader>w_', hidden = true },
    { '<leader>uv', toggle_virtual_text, desc = 'Virtual Text' },

    --                                   ╭──────╮
    --                                   │ Test │
    --                                   ╰──────╯
    { '<leader>t', group = '[T]est', icon = icons.ui.BoxChecked },
    { '<leader>tn', "<Cmd>lua require('neotest').run.run<Cr>", desc = '[T]est [N]earest' },
    { '<leader>tf', "<Cmd>lua require('neotest').run.run(vim.fn.expand('%'))<Cr>", desc = '[T]est Current [F]ile', silent = true },
    { '<leader>td', "<Cmd>lua require('neotest').run.run { strategy = 'dap' }<Cr>", desc = '[T]est [D]ebug (Nearest)', silent = true },
    { '<leader>ts', "<Cmd>lua require('neotest').run.stop<Cr>", desc = '[T]est [S]top' },
    { '<leader>to', "<Cmd>lua require('neotest').output_panel.toggle<Cr>", desc = '[T]est [O]utput Panel' },

    --                                   ╭───────╮
    --                                   │ Debug │
    --                                   ╰───────╯
    { '<leader>d', group = '[D]ebug', icon = icons.diagnostics.Debug },
    { '<leader>dt', "<Cmd>lua require('dap').terminate<CR>", desc = '[T]erminate' },
    { '<leader>dc', "<Cmd>lua require('dap').run_to_cursor<CR>", desc = 'Run to [C]ursor' },
    { '<leader>db', "<Cmd>lua require('dap').toggle_breakpoint<CR>", desc = 'Toggle [B]reakpoint' },
    { '<leader>de', "<Cmd>lua require('dapui').eval<CR>", desc = '[E]val' },
    { '<leader>dB', set_conditional_breakpoint, desc = 'Toggle conditional [B]reakpoint' },
    { '<F1>', "<Cmd>lua require('dap').step_over<CR>", desc = 'Step Over' },
    { '<F2>', "<Cmd>lua require('dap').step_into<CR>", desc = 'Step Into' },
    { '<F3>', "<Cmd>lua require('dap').step_out<CR>", desc = 'Step Out' },
    { '<F5>', "<Cmd>lua require('dap').continue<CR>", desc = 'Start/Continue' },
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    { '<F7>', "<Cmd>lua require('dapui').toggle<CR>", desc = 'See last session result' },

    --                                 ╭───────────╮
    --                                 │ Interface │
    --                                 ╰───────────╯
    { '<leader>u', group = 'Interface', icon = { icon = icons.ui.Gear, color = 'azure' } },
    { '<leader>ub', '<cmd>Barbecue toggle<CR>', desc = 'Toggle [B]arbecue' },
    { '<leader>ui', '<cmd>IlluminateToggle<cr>', desc = '[I]lluminate word highlighting' },
    { '<leader>ul', '<cmd>set number!<cr>', desc = '[L]ine numbers' },
    { '<leader>ur', '<cmd>set relativenumber!<cr>', desc = '[R]elative line numbers' },
    { '<leader>uw', '<cmd>set wrap!<cr>', desc = '[W]rap lines' },
    { '<leader>uc', '<cmd>ColorizerToggle<cr>', desc = '[C]olor highlights' },
    { '<leader>uC', toggle_colorcolumn, desc = '[C]olorcolumn' },
    { '<leader>um', '<cmd>Neominimap toggle<cr>', desc = 'Toggle global [m]inimap' },
    { '<leader>uM', '<cmd>Neominimap bufToggle<cr>', desc = 'Toggle buffer [m]inimap' },
    { '<leader>ug', '<cmd>IBLToggle<cr>', desc = 'Toggle indentation [g]uides' },
    { '<leader>us', toggle_statusline, desc = 'Toggle [s]tatus line' },
    { '<leader>uz', '<cmd>ZenMode<cr>', desc = 'Zen Mode' },
})

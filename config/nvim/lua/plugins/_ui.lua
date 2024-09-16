return {
    -- file explorer
    {
        'nvim-tree/nvim-tree.lua',
        branch = 'master', -- temp for bug fix
        event = 'VimEnter',
        config = function()
            local function on_attach(bufnr)
                local api = require('nvim-tree.api')

                local function opts(desc)
                    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
                end

                api.config.mappings.default_on_attach(bufnr)
                vim.keymap.set('n', 'l', api.node.open.edit, opts('Open'))
                vim.keymap.set('n', 'o', api.node.open.edit, opts('Open'))
                vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open'))
                vim.keymap.set('n', 'v', api.node.open.vertical, opts('Open: Vertical Split'))
                vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts('Close Directory'))
                vim.keymap.set('n', 'C', api.tree.change_root_to_node, opts('CD'))
            end

            local HEIGHT_RATIO = 0.95
            local WIDTH_RATIO = 0.30

            local icons = require('icons')
            local use_icons = true

            require('nvim-tree').setup({
                on_attach = on_attach,
                disable_netrw = true,
                hijack_netrw = true,
                respect_buf_cwd = true,
                sync_root_with_cwd = true,
                view = {
                    centralize_selection = true,
                    adaptive_size = false,
                    side = 'right',
                    preserve_window_proportions = true,
                    float = {
                        enable = true,
                        quit_on_focus_loss = true,
                        open_win_config = function()
                            return {
                                row = 0,
                                width = math.floor(vim.opt.columns:get() * WIDTH_RATIO),
                                border = 'rounded',
                                relative = 'editor',
                                col = vim.o.columns,
                                height = math.floor((vim.opt.lines:get() - vim.opt.cmdheight:get()) * HEIGHT_RATIO),
                            }
                        end,
                    },
                    relativenumber = true,
                    width = function()
                        return math.floor(vim.opt.columns:get() * WIDTH_RATIO)
                    end,
                },
                renderer = {
                    add_trailing = false,
                    group_empty = true, -- ?
                    highlight_git = true,
                    full_name = false,
                    highlight_opened_files = 'none',
                    root_folder_label = ':t',
                    indent_width = 1,
                    indent_markers = {
                        enable = false,
                        inline_arrows = true,
                        icons = {
                            corner = '└',
                            edge = '│',
                            item = '│',
                            none = ' ',
                        },
                    },
                    icons = {
                        webdev_colors = use_icons,
                        git_placement = 'before',
                        padding = ' ',
                        symlink_arrow = ' ➛ ',
                        show = {
                            file = use_icons,
                            folder = use_icons,
                            folder_arrow = use_icons,
                            git = use_icons,
                        },
                        glyphs = {
                            default = icons.ui.Text,
                            symlink = icons.ui.FileSymlink,
                            bookmark = icons.ui.BookMark,
                            folder = {
                                arrow_closed = icons.ui.TriangleShortArrowRight,
                                arrow_open = icons.ui.TriangleShortArrowDown,
                                default = icons.ui.Folder,
                                open = icons.ui.FolderOpen,
                                empty = icons.ui.EmptyFolder,
                                empty_open = icons.ui.EmptyFolderOpen,
                                symlink = icons.ui.FolderSymlink,
                                symlink_open = icons.ui.FolderOpen,
                            },
                            git = {
                                unstaged = icons.git.FileUnstaged,
                                staged = icons.git.FileStaged,
                                unmerged = icons.git.FileUnmerged,
                                renamed = icons.git.FileRenamed,
                                untracked = icons.git.FileUntracked,
                                deleted = icons.git.FileDeleted,
                                ignored = icons.git.FileIgnored,
                            },
                        },
                    },
                    special_files = { 'Cargo.toml', 'Makefile', 'README.md', 'readme.md' },
                    symlink_destination = true,
                },
                update_focused_file = {
                    enable = true,
                    debounce_delay = 15,
                    update_root = true,
                    ignore_list = {},
                },
                filters = {
                    dotfiles = false,
                    git_clean = false,
                    no_buffer = false,
                    custom = { 'node_modules', '\\.cache' },
                    exclude = {},
                },
                -- notify = {
                --     threshold = vim.log.levels.DEBUG,
                -- },
                system_open = {
                    cmd = nil,
                    args = {},
                },
            })
        end,
    },

    -- Useful status updates for LSP
    { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },

    -- statusline
    {
        'nvim-lualine/lualine.nvim',
        event = 'VeryLazy',
        opts = {
            options = {
                icons_enabled = true,
                theme = 'nightfly',
                component_separators = '',
                section_separators = '',
                disabled_filetypes = {
                    'alpha',
                    'intro',
                    'checkhealth',
                    statusline = {},
                    winbar = {},
                },
            },
        },
    },

    {
        'lukas-reineke/indent-blankline.nvim',
        event = { 'BufReadPre', 'BufNewFile' },
        opts = function()
            return {
                indent = {
                    char = '│',
                    tab_char = '│',
                },
                scope = { show_start = false, show_end = false },
                exclude = {
                    filetypes = {
                        'help',
                        'alpha',
                        'dasboard',
                        'nvim-tree',
                        'Trouble',
                        'trouble',
                        'lazy',
                        'mason',
                        'notify',
                    },
                    buftypes = { 'terminal' },
                },
            }
        end,
        main = 'ibl',
    },

    -- minimap
    ---@module "neominimap.config.meta"
    {
        'Isrothy/neominimap.nvim',
        version = 'v3.*.*',
        keys = {
            -- See whichkey configuration
        },
        cmd = 'Neominimap',
        init = function()
            -- The following options are recommended when layout == "float"
            vim.opt.wrap = false
            vim.opt.sidescrolloff = 36 -- Set a large value

            --- Put your configuration here
            ---@type Neominimap.UserConfig
            vim.g.neominimap = {
                auto_enable = false,
                git = {
                    enabled = true,
                    mode = 'sign',
                },
            }
        end,
    },

    -- winbar
    {
        'utilyre/barbecue.nvim',
        name = 'barbecue',
        version = '*',
        event = { 'LspAttach' },
        dependencies = {
            'SmiteshP/nvim-navic',
            'nvim-tree/nvim-web-devicons', -- optional dependency
        },
        opts = {
            show_modified = true,
            context_follow_icon_color = true,
        },
    },

    { 'nvim-tree/nvim-web-devicons' },
}

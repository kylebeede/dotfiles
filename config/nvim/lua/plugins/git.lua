-- Configure vim-rhubarb
vim.g.github_enterprise_urls = { 'git.faithlife.dev' }

-- Because netrw is disabled, :GBrowse requires a custom :Browse implementation. Mac specific
vim.cmd([[
  command! -nargs=* -complete=file Browse execute '!open ' .. shellescape(<q-args>)
]])

return {
    -- Git commands. Can't be lazy loaded
    { 'tpope/vim-fugitive', lazy = false },
    { 'tpope/vim-rhubarb', lazy = false },

    -- Improved diffview for code review
    {
        'sindrets/diffview.nvim',
        -- event = 'BufRead',
        cmd = 'DiffviewOpen',
        dependencies = { 'Mofiqul/vscode.nvim' },
        config = function()
            -- Left panel
            -- "DiffChange:DiffAddAsDelete",
            -- "DiffText:DiffDeleteText",

            -- Right panel
            -- "DiffChange:DiffAdd",
            -- "DiffText:DiffAddText",

            -- local theme = require 'vscode'
            -- theme.load
            vim.cmd([[highlight DiffAdd gui=none guifg=none guibg=#0D311E]])
            vim.cmd([[highlight DiffChange gui=none guifg=none guibg=#272D43]])
            vim.cmd([[highlight DiffText gui=none guifg=none guibg=#394b70]])
            -- vim.cmd [[highlight DiffDelete gui=none guifg=none guibg=#470909]]
            vim.cmd([[highlight DiffDelete gui=none guifg=none guibg=#360707]])

            vim.cmd([[highlight DiffAddText gui=none guifg=none guibg=#1D7246]])
            -- vim.cmd [[highlight DiffAddAsDelete gui=none guifg=none guibg=#3F2D3D]]
            vim.cmd([[highlight DiffDeleteText gui=none guifg=none guibg=#5D1D1D]])

            -- vim.cmd [[highlight DiffviewDiffAddAsDelete guibg=#3f2d3d gui=none guifg=none]]
            -- vim.cmd [[highlight DiffviewDiffAddAsDelete guibg=#3f2d3d gui=none guifg=none]]
            -- vim.cmd [[highlight DiffviewDiffDelete gui=none guifg=#3B4252 guibg=none]]

            require('diffview').setup({
                enhanced_diff_hl = true,
                hooks = {
                    ---@param view StandardView
                    view_opened = function(view)
                        local utils = require('../../utils')
                        -- Highlight 'DiffChange' as 'DiffDelete' on the left, and 'DiffAdd' on
                        -- the right.
                        local function post_layout()
                            utils.tbl_ensure(view, 'winopts.diff2.a')
                            utils.tbl_ensure(view, 'winopts.diff2.b')
                            -- left
                            view.winopts.diff2.a = utils.tbl_union_extend(view.winopts.diff2.a, {
                                winhl = {
                                    'DiffChange:DiffAddAsDelete',
                                    'DiffText:DiffDeleteText',
                                },
                            })
                            -- right
                            view.winopts.diff2.b = utils.tbl_union_extend(view.winopts.diff2.b, {
                                winhl = {
                                    'DiffChange:DiffAdd',
                                    'DiffText:DiffAddText',
                                },
                            })
                        end

                        view.emitter:on('post_layout', post_layout)
                        post_layout()
                    end,
                },
            })
        end,
    },
}

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
            local theme = require('config.theme')
            vim.cmd(string.format('highlight DiffAdd gui=none guifg=none guibg=%s', theme.highlights.diffAddBg))
            vim.cmd(string.format('highlight DiffAddText gui=none guifg=%s guibg=%s', theme.highlights.diffAddText, theme.highlights.diffAddFg))

            vim.cmd(string.format('highlight DiffAddAsDelete gui=none guifg=none guibg=%s', theme.highlights.diffDeleteBg))
            vim.cmd(string.format('highlight DiffDeleteText gui=none guifg=%s guibg=%s', theme.highlights.diffDeleteText, theme.highlights.diffDeleteFg))

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

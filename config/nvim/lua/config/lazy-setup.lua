---------- CONFIGURE LAZY ----------
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
    spec = {
        { import = '../themes' },
        { import = '../plugins' },
    },
    defaults = {
        lazy = true,
    },
    install = { colorscheme = { 'nightfly', 'default' } },
    checker = {
        enabled = true,
        notify = true,
        frequency = 604800, -- Check for updates every week
    },
    ui = {
        size = { width = 0.9, height = 0.9 },
        border = 'rounded',
    },
    debug = false,
    change_detection = { enabled = false },
    rtp = {
        reset = true,
        ---@type string[]
        paths = {},
        ---@type string[]
        -- disabled_plugins = {
        --   'netrwPlugin',
        --   'tohtml',
        --   'tutor',
        --   'gzip',
        --   'rplugin',
        --   'tarPlugin',
        --   'tohtml',
        --   'tutor',
        --   'zipPlugin',
        -- },
    },
})

-- vim: ts=2 sts=2 sw=2 et

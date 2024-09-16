vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- TODO: research this
-- vim.loader.enable()

-- disable netrw (for nvim-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- enable 24-bit colour
vim.opt.termguicolors = true

vim.opt.fillchars = { eob = ' ', diff = '/', fold = ' ' }

vim.opt.autoindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

vim.opt.scrolloff = 12

vim.opt.conceallevel = 1

-- Set highlight on search
vim.o.hlsearch = false

-- Active line has absolute line number, others relative
vim.wo.number = true
vim.wo.relativenumber = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

vim.o.cursorline = true

vim.filetype.add({
    extension = {
        fsd = 'fsd',
    },
})

-- Enable folding
vim.o.foldmethod = 'indent'

-- Start with all folds open
vim.o.foldlevelstart = 20

-- vim: ts=2 sts=2 sw=2 et

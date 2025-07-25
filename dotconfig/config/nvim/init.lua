-- basic
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.cursorcolumn = true

vim.o.scrolloff = 5
vim.o.sidescrolloff = 5

vim.o.mouse = 'a'
vim.o.mousemoveevent = true

vim.o.list = true
vim.o.listchars = 'tab:>-,trail:-'

vim.o.tabstop = 8
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

vim.o.wrap = false
vim.o.swapfile = false

vim.o.foldlevelstart = 99

-- move
vim.keymap.set({ 'n', 'v' }, 'H', '^')
vim.keymap.set({ 'n', 'v' }, 'L', '$')
vim.keymap.set({ 'n', 'v' }, 'J', '10j')
vim.keymap.set({ 'n', 'v' }, 'K', '10k')
vim.keymap.set({ 'n', 'v' }, 'W', 'b')
vim.keymap.set({ 'n', 'v' }, 'E', 'ge')

vim.keymap.set('i', '<A-h>', '<left>')
vim.keymap.set('i', '<A-j>', '<down>')
vim.keymap.set('i', '<A-k>', '<up>')
vim.keymap.set('i', '<A-l>', '<right>')

-- copy, cut, delete
vim.keymap.set('n', 'dl', 'd$')
vim.keymap.set('n', 'dh', 'd0')

vim.keymap.set('n', '<C-v>', '"+p')
vim.keymap.set('v', '<C-x>', '"+x')
vim.keymap.set('v', '<C-c>', '"+y')

-- window
vim.keymap.set('n', 'sp', '<C-w>s')
vim.keymap.set('n', 'vs', '<C-w>v')

vim.keymap.set('n', '<A-h>', '<C-w>h')
vim.keymap.set('n', '<A-j>', '<C-w>j')
vim.keymap.set('n', '<A-k>', '<C-w>k')
vim.keymap.set('n', '<A-l>', '<C-w>l')

-- exit
vim.keymap.set('n', '<C-s>', '<cmd>w<cr>')
vim.keymap.set('n', '<leader>qw', '<cmd>q<cr>')
vim.keymap.set('n', '<leader>qq', '<cmd>wq<cr>')
vim.keymap.set('n', '<leader>qa', '<cmd>wqa<cr>')

-- misc
vim.keymap.set({ 'n', 'v', 'i' }, '<up>', '<nop>')
vim.keymap.set({ 'n', 'v', 'i' }, '<down>', '<nop>')
vim.keymap.set({ 'n', 'v', 'i' }, '<left>', '<nop>')
vim.keymap.set({ 'n', 'v', 'i' }, '<right>', '<nop>')

-- lazy nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({ { import = 'plugins' } })


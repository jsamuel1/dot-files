vim.loader.enable()
require 'plugins'

--vim.notify = require 'notify'

local g = vim.g
local cmd = vim.cmd

-- Leader/local leader
g.mapleader = [[ ]]
g.maplocalleader = [[,]]

-- Skip some remote provider loading
g.loaded_python3_provider = 0
g.loaded_node_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0

-- Disable some built-in plugins we don't want
local disabled_built_ins = {
  'gzip',
  'man',
  'matchit',
  'matchparen',
  'shada_plugin',
  'tarPlugin',
  'tar',
  'zipPlugin',
  'zip',
  'netrwPlugin',
}

for i = 1, 10 do
  g['loaded_' .. disabled_built_ins[i]] = 1
end

-- Settings
local opt = vim.opt
opt.textwidth = 100
opt.scrolloff = 7
opt.wildignore = { '*.o', '*~', '*.pyc', '*.obj', '*.svn', '*.swp', '*.class', '*.DS_Store', '*.git', '__pycache__', '*.min.*' }
opt.wildmode = 'longest,list,full'
opt.whichwrap:append '<,>,h,l'
opt.inccommand = 'nosplit'
opt.lazyredraw = true
opt.showmatch = true
opt.ignorecase = true
opt.smartcase = true
opt.tabstop = 2
opt.softtabstop = 0
opt.expandtab = true
opt.shiftwidth = 2
opt.number = true
opt.relativenumber = false
opt.smartindent = true
opt.laststatus = 3
opt.showmode = false
opt.shada = [['20,<50,s10,h,/100]]
opt.hidden = true
opt.shortmess:append 'c'
opt.joinspaces = false
opt.guicursor = [[n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50]]
opt.updatetime = 100
opt.conceallevel = 2
opt.concealcursor = 'nc'
opt.previewheight = 5
opt.undofile = true
opt.synmaxcol = 500
opt.display = 'msgsep'
opt.cursorline = true
opt.modeline = false
opt.mouse = 'nivh'
opt.signcolumn = 'yes:1'
opt.rtp:append '/.fzf'
opt.encoding = 'utf8'

-- Colorscheme
opt.termguicolors = true
opt.background = 'dark'


-- Autocommands
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
autocmd('VimEnter', {
  group = augroup('start_screen', { clear = true }),
  once = true,
  callback = function()
    require('start').start()
  end,
})
local misc_aucmds = augroup('misc_aucmds', { clear = true })
autocmd('BufWinEnter', { group = misc_aucmds, command = 'checktime' })

-- Highlight and underline on 99 characters
autocmd('BufWinEnter', { group = misc_aucmds, command = "match SpellBad /\\%>98v.*\\%<101v/" }) 

autocmd('TextYankPost', {
  group = misc_aucmds,
  callback = function()
    vim.highlight.on_yank()
  end,
})
autocmd('FileType', { group = misc_aucmds, pattern = 'qf', command = 'set nobuflisted' })

-- Commands
local create_cmd = vim.api.nvim_create_user_command
create_cmd('PackerInstall', function()
  cmd [[packadd packer.nvim]]
  require('plugins').install()
end, {})
create_cmd('PackerUpdate', function()
  cmd [[packadd packer.nvim]]
  require('plugins').update()
end, {})
create_cmd('PackerSync', function()
  cmd [[packadd packer.nvim]]
  require('plugins').sync()
end, {})
create_cmd('PackerClean', function()
  cmd [[packadd packer.nvim]]
  require('plugins').clean()
end, {})
create_cmd('PackerCompile', function()
  cmd [[packadd packer.nvim]]
  require('plugins').compile()
end, {})

-- Keybindings
local silent = { silent = true, noremap = true }

-- Quit, close buffers, etc.
local map = vim.api.nvim_set_keymap
map('n', '<leader>q', '<cmd>qa<cr>', silent)
map('n', '<leader>x', '<cmd>x!<cr>', silent)
map('n', '<leader>d', '<cmd>Sayonara<cr>', { silent = true, nowait = true, noremap = true })

-- Save buffer
map('i', '<c-s>', '<esc><cmd>w<cr>a', silent)
map('n', '<leader>w', '<cmd>w<cr>', silent)

-- Version control
map('n', 'gs', '<cmd>Neogit<cr>', silent)

-- Esc in the terminal
map('t', 'jj', [[<C-\><C-n>]], silent)

-- Yank to clipboard
map('n', 'y+', '<cmd>set opfunc=util#clipboard_yank<cr>g@', silent)
map('v', 'y+', '<cmd>set opfunc=util#clipboard_yank<cr>g@', silent)

-- Window movement
map('n', '<c-h>', '<c-w>h', silent)
map('n', '<c-j>', '<c-w>j', silent)
map('n', '<c-k>', '<c-w>k', silent)
map('n', '<c-l>', '<c-w>l', silent)

-- Tab movement
map('n', '<c-Left>', '<cmd>tabpre<cr>', silent)
map('n', '<c-Right>', '<cmd>tabnext<cr>', silent)


-- cmd [[colorscheme gruvbox-material]]
-- cmd [[colorscheme nazgul]]
-- cmd [[colorscheme base16-gruvbox-light-hard]]
cmd [[colorscheme base16-default-dark]]

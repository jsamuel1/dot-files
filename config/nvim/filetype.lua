-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- UI config
vim.opt.number = true -- show absolute number
vim.opt.relativenumber = false -- add numbers to each line on the left side
vim.opt.cursorline = true -- highlight cursor line underneath the cursor horizontally
vim.opt.termguicolors = true -- enabl 24-bit RGB color in the TUI
vim.opt.foldlevel = 99

-- Searching
vim.opt.incsearch = true -- search as characters are entered
vim.opt.ignorecase = true -- ignore case in searches by default
vim.opt.smartcase = true -- but make it case sensitive if an uppercase is entered

vim.filetype.add({
  extension = {
    dockerfile = "dockerfile",
  },
  pattern = {
    ["[Dd]ockerfile.*"] = "dockerfile",
  },
})

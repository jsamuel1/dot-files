-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
if vim.g.vscode then
  -- Toggle Comment
  vim.keymap.set("x", "gc", "<Plug>VSCodeCommentary", {})
  vim.keymap.set("n", "gc", "<Plug>VSCodeCommentary", {})
  vim.keymap.set("o", "gc", "<Plug>VSCodeCommentary", {})
  vim.keymap.set("n", "gcc", "<Plug>VSCodeCommentaryLine", {})
end

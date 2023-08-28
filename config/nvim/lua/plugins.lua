-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)


-- Reload configurations if we modify plugins.lua
-- Hint
--     <afile> - replaced with the filename of the buffer being manipulated
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | Lazy sync 
  augroup end
]])


require('lazy').setup({

        -- LSP manager
        { 'williamboman/mason.nvim' },
        { 'williamboman/mason-lspconfig.nvim' },
        { 'neovim/nvim-lspconfig' },
        { 'folke/neodev.nvim' },

        -- Add hooks to LSP to support Linter && Formatter
        { 'nvim-lua/plenary.nvim' },
        {
            'jay-babu/mason-null-ls.nvim',
            dependencies = { 'jose-elias-alvarez/null-ls.nvim' },
            config=[[require('config.mason-null-ls')]]
        },

        -- Vscode-like pictograms
        { 'onsails/lspkind.nvim', event = 'VimEnter' },

        -- Auto-completion engine
        -- Note:
        --     the default search path for `require` is ~/.config/nvim/lua
        --     a `.` as a path seperator
        --     the suffix `.lua` is not needed
        { 'hrsh7th/nvim-cmp',  config = [[require('config.nvim-cmp')]] },
        { 'hrsh7th/cmp-nvim-lsp'  },
        { 'hrsh7th/cmp-buffer' }, -- buffer auto-completion
        { 'hrsh7th/cmp-path' }, -- path auto-completion
        { 'hrsh7th/cmp-cmdline' }, -- cmdline auto-completion


        -- Code snippet engine
        'L3MON4D3/LuaSnip',
        { 'saadparwaiz1/cmp_luasnip', after = { 'nvim-cmp', 'LuaSnip' } },

        -- Colorschemes
        { 'tanvirtin/monokai.nvim', lazy = true},
        { 'navarasu/onedark.nvim', lazy = true},

        -- Git integration
        'tpope/vim-fugitive',

        -- Git decorations
        { 'lewis6991/gitsigns.nvim', config = [[require('config.gitsigns')]] },

        -- Autopairs: [], (), "", '', etc
        -- it relies on nvim-cmp
        {
            "windwp/nvim-autopairs",
            after = 'nvim-cmp',
            config = [[require('config.nvim-autopairs')]],
        },

        -- Code comment helper
        --     1. `gcc` to comment a line
        --     2. select lines in visual mode and run `gc` to comment/uncomment lines
        'tpope/vim-commentary',

        -- Treesitter-integration
        {
            'nvim-treesitter/nvim-treesitter',
            dependencies = {
                'nvim-treesitter/nvim-treesitter-textobjects',
            },
            build = ':TSUpdate',
            config = [[require('config.nvim-treesitter')]],
        },

        -- Show indentation and blankline
        { 'lukas-reineke/indent-blankline.nvim', config = [[require('config.indent-blankline')]] },

        -- Status line
        {
            'nvim-lualine/lualine.nvim',
            dependencies = { 'nvim-tree/nvim-web-devicons', lazy = true },
            config = [[require('config.lualine')]],
        },

        -- Markdown support
        { 'preservim/vim-markdown', ft = { 'markdown' } },

        -- Markdown previewer
        -- It require nodejs and yarn. homebrew to install first
        {
            "iamcco/markdown-preview.nvim",
            build = "cd app && npm install",
            setup = function() vim.g.mkdp_filetypes = { "markdown" } end,
            ft = { "markdown" },
        },

        -- Smart indentation for Python
        { "Vimjas/vim-python-pep8-indent", ft = { "python" } },

        -- File explorer
        {
            'nvim-tree/nvim-tree.lua',
            dependencies = {
                'nvim-tree/nvim-web-devicons', -- optional, for file icons
            },
            config = [[require('config.nvim-tree')]]
        },

        -- Smart motion
        {
            'phaazon/hop.nvim',
            branch = 'v2', -- optional but strongly recommended
            config = function()
                -- you can configure Hop the way you like here; see :h hop-config
                require'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
            end
        },

        -- Better terminal integration
        -- tag = string,                -- Specifies a git tag to use. Supports '*' for "latest tag"
        { "akinsho/toggleterm.nvim", version = "*", config = [[require('config.toggleterm')]] },


}, {})


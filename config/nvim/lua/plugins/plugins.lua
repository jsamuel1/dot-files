return {

  -- Vscode-like pictograms
  { "onsails/lspkind.nvim", event = "VimEnter" },

  -- Auto-completion engine
  -- Note:
  --     the default search path for `require` is ~/.config/nvim/lua
  --     a `.` as a path seperator
  --     the suffix `.lua` is not needed
  { "hrsh7th/nvim-cmp", config = [[require('config.nvim-cmp')]] },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" }, -- buffer auto-completion
  { "hrsh7th/cmp-path" }, -- path auto-completion
  { "hrsh7th/cmp-cmdline" }, -- cmdline auto-completion

  -- Code snippet engine
  "L3MON4D3/LuaSnip",
  { "saadparwaiz1/cmp_luasnip", after = { "nvim-cmp", "LuaSnip" } },

  -- Colorschemes
  { "tanvirtin/monokai.nvim", lazy = true },
  { "navarasu/onedark.nvim", lazy = true },

  -- Git integration
  "tpope/vim-fugitive",

  -- Git decorations
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("config.gitsigns")
    end,
  },

  -- Treesitter-integration
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("config.nvim-treesitter")
    end,
  },

  -- Show indentation and blankline
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("config.indent-blankline")
    end,
  },

  -- Markdown support
  { "preservim/vim-markdown", ft = { "markdown" } },

  -- Markdown previewer
  -- It require nodejs and yarn. homebrew to install first
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    setup = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },

  -- Smart indentation for Python
  { "Vimjas/vim-python-pep8-indent", ft = { "python" } },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- optional, for file icons
    },
    config = function()
      require("config.nvim-tree")
    end,
  },

  -- Better terminal integration
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("config.toggleterm")
    end,
  },
}

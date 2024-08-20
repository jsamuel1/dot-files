return {
  -- Vscode-like pictograms
  -- { "onsails/lspkind.nvim", event = "VimEnter", vscode = true },

  -- Auto-completion engine
  -- Note:
  --     the default search path for `require` is ~/.config/nvim/lua
  --     a `.` as a path seperator
  --     the suffix `.lua` is not needed
  -- { "hrsh7th/nvim-cmp", config = [[require('config.nvim-cmp')]], dependencies = { "hrsh7th/cmp-emoji" } },
  -- { "hrsh7th/cmp-nvim-lsp" },
  -- { "hrsh7th/cmp-buffer" }, -- buffer auto-completion
  -- { "hrsh7th/cmp-path" }, -- path auto-completion
  -- { "hrsh7th/cmp-cmdline" }, -- cmdline auto-completion

  {
    "neovim/nvim-lspconfig",
    cmd = function()
      local lspconfig = require("lspconfig")
      local configs = require("lspconfig.configs")
      if not configs.codewhisperer then
        configs.codewhisperer = {
          default_config = {
            -- Add the codewhisperer to our PATH or BIN folder
            cmd = { "cwls" },
            root_dir = lspconfig.util.root_pattern(
              "packageInfo",
              "package.json",
              "tsconfig.json",
              "jsconfig.json",
              ".git"
            ),
            filetypes = {
              "java",
              "python",
              "typescript",
              "javascript",
              "csharp",
              "ruby",
              "kotlin",
              "shell",
              "sql",
              "c",
              "cpp",
              "go",
              "rust",
              "lua",
            },
          },
        }
      end
      lspconfig.codewhisperer.setup({})
    end,
  },
  -- Treesitter-integration
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
       vim.list_extend(opts.ensure_installed, {
         "comment", -- for tags like TODO:, FIXME(user)
         "dockerfile",
         "gitattributes",
         "gitcommit",
         "gitignore",
       })
      -- Install parsers synchronously (only applied to `ensure_installed`)
      opts.sync_install = false
      -- Automatically install missing parsers when entering buffer
      -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
      opts.auto_install = true
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

  -- Smart indentation for Python
  { "Vimjas/vim-python-pep8-indent", ft = { "python" } },

  -- Better terminal integration
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("config.toggleterm")
    end,
  },

  {
    "williamboman/mason.nvim",
    vscode = true 
  },
}

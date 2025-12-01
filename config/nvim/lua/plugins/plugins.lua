return {
  -- Enable Snacks picker
  {
    "folke/snacks.nvim",
    opts = {
      picker = { enabled = true },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
        inlay_hints = { enabled = false },
        servers = {
          basedpyright = {
            settings = {
              basedpyright = {
                analysis = {
                  ignorePatterns = { "*.pyi" },
                  diagnosticSeverityOverrides = {
                    reportCallIssue = "warning",
                    reportUnreachable = "warning",
                    reportUnusedImport = "none",
                    reportUnusedCoroutine = "warning",
                  },
                  -- diagnosticMode = "workspace",
                  diagnosticMode = "openFilesOnly",
                  typeCheckingMode = "basic",
                  reportCallIssue = "none",
                  disableOrganizeImports = true,
                },
              },
            },
          },
        },
    }
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

  -- Smart indentation for Python
  { "Vimjas/vim-python-pep8-indent", ft = { "python" } },

  {
    name = "amazonq",
    url = 'https://github.com/awslabs/amazonq.nvim.git',
    -- url = "ssh://git.amazon.com/pkg/AmazonQNVim",
    -- dir = "~/src/AmazonQNVim/src/aws/AmazonQNVim/",
    opts = {
      ssoStartUrl = "https://amzn.awsapps.com/start",
      -- debug = true,
    },
  },
}

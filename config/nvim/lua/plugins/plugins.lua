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
}

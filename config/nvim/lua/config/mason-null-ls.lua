require("mason").setup()
require("mason-lspconfig").setup({
  -- A list of sources to install if they're not already installed.
  -- This setting has no relation with the `automatic_installation` setting.
  ensure_installed = {
    "black",
    "stylua",
    "lua_ls",
    "rust_analyzer",
    "taplo",
    "tflint",
    "yamlls",
    "tsserver",
    "autotools-language-server",
  },
  automatic_installation = { exclude = { "rust_analyzer" } },
  handlers = {},
})

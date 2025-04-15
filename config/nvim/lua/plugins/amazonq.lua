return {
  {
    -- Amazon Q Chat for Neovim
    dir = "/Users/sauhsoj/src/AmazonQNVim/src/AmazonQNVim",
    name = "amazonq-chat-nvim",
    lazy = false,
    priority = 100,
    config = function()
      require("amazonq").setup({
        -- Using default configuration
      })
      require("amazonqchat").setup({
        -- Using default configuration
      })
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
  },
}


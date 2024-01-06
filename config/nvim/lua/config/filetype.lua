vim.filetype.add({
  extension = {
    dockerfile = "dockerfile",
  },
  pattern = {
    ["[Dd]ockerfile*"] = "dockerfile",
  },
})

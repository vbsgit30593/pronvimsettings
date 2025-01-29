return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 500
  end,
  config = function()
    local wk = require("which-key")
    wk.add({
      { "<leader>r", group = "Upload / Download", icon = "" },
      {
        "<leader>rd",
        "<cmd>TransferDownload<cr>",
        desc = "Download from remote server (scp)",
        icon = { color = "green", icon = "󰇚" },
      },
      {
        "<leader>rf",
        "<cmd>DiffRemote<cr>",
        desc = "Diff file with remote server (scp)",
        icon = { color = "green", icon = "" },
      },
      {
        "<leader>ri",
        "<cmd>TransferInit<cr>",
        desc = "Init/Edit Deployment config",
        icon = { color = "green", icon = "" },
      },
      {
        "<leader>rr",
        "<cmd>TransferRepeat<cr>",
        desc = "Repeat transfer command",
        icon = { color = "green", icon = "󰑖" },
      },
      {
        "<leader>ru",
        "<cmd>TransferUpload<cr>",
        desc = "Upload to remote server (scp)",
        icon = { color = "green", icon = "󰕒" },
      },
    })
  end,
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
}

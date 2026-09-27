-- ============================================================================
-- File explorer + fast in-project navigation
-- ============================================================================

return {
  -- Tree-style sidebar explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>ee", "<cmd>Neotree toggle reveal<CR>", desc = "Toggle file explorer" },
      { "<leader>ef", "<cmd>Neotree reveal<CR>",        desc = "Reveal current file in explorer" },
      { "<leader>n",  "<cmd>Neotree toggle reveal<CR>", desc = "Toggle file tree" },
    },
    opts = {
      close_if_last_window = true,
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = { ".git", "__pycache__", ".DS_Store" },
        },
      },
      window = { width = 32 },
    },
  },

  -- Edit the filesystem like a buffer (rename/move files with normal editing)
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = {
      { "-", "<cmd>Oil<CR>", desc = "Open parent directory (oil)" },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      view_options = { show_hidden = true },
      skip_confirm_for_simple_edits = true,
    },
  },

  -- f/t/s motions on steroids
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,       desc = "Flash jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter select" },
    },
  },

  -- Pin files and jump between them instantly
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>a", function() require("harpoon"):list():add() end,     desc = "Harpoon: add file" },
      {
        "<leader>h",
        function()
          local harpoon = require("harpoon")
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = "Harpoon: menu"
      },
      { "<M-1>",     function() require("harpoon"):list():select(1) end, desc = "Harpoon file 1" },
      { "<M-2>",     function() require("harpoon"):list():select(2) end, desc = "Harpoon file 2" },
      { "<M-3>",     function() require("harpoon"):list():select(3) end, desc = "Harpoon file 3" },
      { "<M-4>",     function() require("harpoon"):list():select(4) end, desc = "Harpoon file 4" },
    },
    config = function()
      require("harpoon"):setup()
    end,
  },

  -- Pretty diagnostics / references / quickfix list
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>",              desc = "Diagnostics (project)" },
      { "<leader>xd", "<cmd>Trouble diagnostics toggle<CR>",              desc = "All diagnostics (project)" },
      { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Diagnostics (buffer)" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<CR>",      desc = "Symbols outline" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<CR>",                   desc = "Quickfix list" },
      { "<leader>xt", "<cmd>Trouble todo toggle<CR>",                     desc = "TODO comments" },
    },
  },

  -- Highlight and search TODO/FIXME/HACK/NOTE comments
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      { "]t",         function() require("todo-comments").jump_next() end, desc = "Next TODO comment" },
      { "[t",         function() require("todo-comments").jump_prev() end, desc = "Previous TODO comment" },
      { "<leader>ft", "<cmd>TodoTelescope<CR>",                            desc = "Find TODOs" },
    },
  },
}

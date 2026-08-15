-- ============================================================================
-- Editing quality-of-life
-- ============================================================================

return {
  -- Auto-close brackets/quotes, aware of treesitter
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = { check_ts = true },
  },

  -- Surround: ys/cs/ds motions ("surround word with quotes" etc.)
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  -- Comment toggling: gcc (line), gc (motion/visual). Uses &commentstring.
  -- Built into Neovim 0.10+; ts-context-commentstring fixes embedded langs.
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    opts = { enable_autocmd = false },
  },

  -- Split/join code blocks (function args, dicts, structs) with <leader>j
  {
    "Wansmer/treesj",
    keys = {
      { "<leader>j", function() require("treesj").toggle() end, desc = "Split/join code block" },
    },
    opts = { use_default_keymaps = false, max_join_length = 200 },
  },

  -- Better text objects: ci( from anywhere in line, aI for indentation, etc.
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = {},
  },

  -- Undo history as a browsable tree
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    keys = {
      { "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "Toggle undo tree" },
    },
  },

  -- Integrated terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<C-\\>", desc = "Toggle terminal" },
      { "<leader>tt", "<cmd>ToggleTerm direction=float<CR>", desc = "Floating terminal" },
    },
    opts = {
      open_mapping = [[<C-\>]],
      direction = "horizontal",
      size = 15,
      shade_terminals = true,
    },
  },
}

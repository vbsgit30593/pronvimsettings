-- ============================================================================
-- Colorscheme, statusline, and general UI
-- ============================================================================

return {
  -- Colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      integrations = {
        blink_cmp = true,
        gitsigns = true,
        mason = true,
        native_lsp = { enabled = true },
        treesitter = true,
        which_key = true,
        dap = true,
        dap_ui = true,
        markdown = true,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        theme = "catppuccin",
        globalstatus = true,
        component_separators = { left = "│", right = "│" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = {
          -- Show attached LSP clients
          {
            function()
              local clients = vim.lsp.get_clients({ bufnr = 0 })
              if #clients == 0 then return "" end
              local names = {}
              for _, c in ipairs(clients) do
                table.insert(names, c.name)
              end
              return " " .. table.concat(names, ",")
            end,
          },
          "encoding",
          "filetype",
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  -- Keymap discovery popup
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        { "<leader>e", group = "explorer" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>r", group = "rename/restart" },
        { "<leader>c", group = "code" },
        { "<leader>s", group = "split" },
        { "<leader>t", group = "tab/toggle" },
        { "<leader>w", group = "session/write" },
        { "<leader>x", group = "trouble" },
        { "<leader>d", group = "debug" },
      },
    },
  },

  -- LSP progress notifications in the corner (shows clangd indexing, etc.).
  -- This replaces the progress display noice used to provide — noice is
  -- disabled in this config, and fidget is a lighter, non-intrusive way to
  -- see "indexing…" and other LSP task status.
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      progress = {
        display = {
          done_icon = "✓",
        },
      },
      notification = {
        window = {
          winblend = 0, -- transparent background, plays nice over SSH/tmux
        },
      },
    },
  },

  -- Nicer messages, cmdline, and LSP progress.
  -- DISABLED BY DEFAULT: noice replaces Neovim's message/cmdline UI with
  -- floating windows. Over SSH / in some terminals this can grab focus, hide
  -- command output (`:set ft?` echoes nothing), and make buffers report
  -- filetype "noice" — which masquerades as an LSP failure. Flip enabled=true
  -- if you want it back once the terminal is known-good.
  {
    "folke/noice.nvim",
    enabled = false,
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
    },
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = { char = "│" },
      scope = { enabled = true, show_start = false, show_end = false },
      exclude = { filetypes = { "help", "lazy", "mason", "markdown" } },
    },
  },

  -- Session persistence (josean-style keys):
  --   <leader>wr restores the session for the current directory (your tabs/splits)
  --   <leader>ws saves the current session
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
      { "<leader>wr", function() require("persistence").load() end, desc = "Restore session for cwd" },
      { "<leader>ws", function() require("persistence").save() end, desc = "Save session for cwd" },
    },
  },
}

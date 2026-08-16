-- ============================================================================
-- Git integration
-- ============================================================================

return {
  -- Gutter signs, hunk actions, inline blame
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      -- current_line_blame = false, -- toggle with <leader>gb
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 300,
        ignore_whitespace = false,
      },
      current_line_blame_formatter = "  <author>, <author_time:%Y-%m-%d> · <summary>",
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function bmap(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        bmap("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next git hunk")
        bmap("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Previous git hunk")

        bmap({ "n", "v" }, "<leader>gh", gs.stage_hunk, "Stage hunk")
        bmap({ "n", "v" }, "<leader>gr", gs.reset_hunk, "Reset hunk")
        bmap("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
        bmap("n", "<leader>gB", function() gs.blame_line({ full = true }) end, "Blame line (full)")
        bmap("n", "<leader>gb", gs.toggle_current_line_blame, "Toggle inline blame")
        bmap("n", "<leader>gd", gs.diffthis, "Diff against index")
      end,
    },
  },

  -- Full-featured diff/merge view and file history
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<CR>",          desc = "Open diff view" },
      { "<leader>gf", "<cmd>DiffviewFileHistory %<CR>", desc = "File history (current file)" },
    },
    opts = {},
  },

  -- Magit-style git interface
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
    keys = {
      { "<leader>gg", "<cmd>Neogit<CR>", desc = "Open Neogit" },
    },
    opts = { integrations = { diffview = true } },
  },

  -- LazyGit (josean's <leader>lg) — needs the `lazygit` CLI installed
  --   macOS: brew install lazygit   |   OL9: sudo dnf install -y lazygit (EPEL)
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>lg", "<cmd>LazyGit<CR>", desc = "Open LazyGit" },
    },
  },
}

-- ============================================================================
-- fzf-lua: the single fuzzy-finder engine for this config.
--
-- We use fzf-lua for EVERYTHING (files, grep, LSP pickers, git, buffers,
-- diagnostics, symbols, help, keymaps). Telescope was removed because it's
-- written against nvim-treesitter's `master` API and crashes on the `main`
-- branch we run ("attempt to call field 'ft_to_lang'"). fzf-lua uses its own
-- previewer and is faster on large repos anyway.
--
-- Requires the `fzf` binary on PATH (brew install fzf / dnf install fzf).
-- Keymaps follow the josean-style <leader>f* scheme.
-- ============================================================================

return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "FzfLua",
    keys = {
      -- ---- Files / buffers ------------------------------------------------
      {
        "<leader>ff",
        function()
          local fzf = require("fzf-lua")
          local in_git = vim.fn.systemlist({ "git", "rev-parse", "--is-inside-work-tree" })[1] == "true"
          if in_git then fzf.git_files() else fzf.files() end
        end,
        desc = "Find files (fast, git-aware)",
      },
      { "<leader>fF", function() require("fzf-lua").files() end, desc = "Find all files (fd)" },
      { "<leader><leader>", function() require("fzf-lua").buffers() end, desc = "Open buffers" },
      { "<leader>fr", function() require("fzf-lua").oldfiles() end, desc = "Recent files" },

      -- ---- Grep -----------------------------------------------------------
      { "<leader>fs", function() require("fzf-lua").live_grep() end, desc = "Live grep (fast)" },
      { "<leader>fc", function() require("fzf-lua").grep_cword() end, desc = "Grep string under cursor" },
      { "<leader>fc", function() require("fzf-lua").grep_visual() end, mode = "v", desc = "Grep selection" },
      { "<leader>f/", function() require("fzf-lua").lgrep_curbuf() end, desc = "Grep in current buffer" },

      -- ---- Diagnostics / help / meta -------------------------------------
      { "<leader>fd", function() require("fzf-lua").diagnostics_document() end, desc = "Diagnostics (buffer)" },
      { "<leader>fD", function() require("fzf-lua").diagnostics_workspace() end, desc = "Diagnostics (project)" },
      { "<leader>fh", function() require("fzf-lua").help_tags() end, desc = "Help tags" },
      { "<leader>fk", function() require("fzf-lua").keymaps() end, desc = "Keymaps" },
      { "<leader>fC", function() require("fzf-lua").commands() end, desc = "Commands" },
      { "<leader>fp", function() require("fzf-lua").resume() end, desc = "Resume last picker" },

      -- ---- Git ------------------------------------------------------------
      { "<leader>gc", function() require("fzf-lua").git_commits() end, desc = "Git commits" },
      { "<leader>gs", function() require("fzf-lua").git_status() end, desc = "Git status" },
    },
    opts = {
      files = {
        fd_opts = "--type f --hidden --follow --exclude .git --exclude node_modules --exclude build --exclude .cache",
        git_icons = false,
        file_icons = false,
        color_icons = false,
      },
      grep = {
        rg_opts = "--column --line-number --no-heading --smart-case --hidden --glob '!**/.git/*'",
        git_icons = false,
        file_icons = false,
        color_icons = false,
      },
      lsp = {
        -- Jump straight to the location if there's only one result.
        jump1 = true,
        -- Put references/etc. in the fzf window; async so large sets stream in.
        async_or_timeout = 5000,
        git_icons = false,
        file_icons = false,
      },
      previewers = {
        builtin = {
          syntax = true,
          treesitter = { enabled = true },
        },
      },
      winopts = {
        height = 0.85,
        width = 0.85,
        preview = {
          default = "builtin",
          layout = "flex",
          scrollbar = "float",
        },
      },
    },
  },
}

-- ============================================================================
-- Treesitter (Neovim 0.12+, `main` branch)
--
-- IMPORTANT: this uses the rewritten `main` branch of nvim-treesitter, which is
-- the ONLY branch compatible with Neovim 0.12. The old `master` branch is
-- frozen and causes the "attempt to call method 'range'/'start' (a nil value)"
-- crashes (including on LSP hover, which renders docs as markdown).
--
-- The main branch is just a parser installer — it no longer has a module system
-- or `ensure_installed`. We enable highlighting/indentation ourselves via a
-- FileType autocmd and install parsers via its install() API.
--
-- Requires the tree-sitter CLI on PATH (the main branch compiles parsers):
--   macOS: brew install tree-sitter
--   OL9:   sudo dnf install -y tree-sitter-cli   (or: npm install -g tree-sitter-cli)
-- ============================================================================

local ensure_installed = {
  "c", "cpp", "python",
  "bash", "markdown", "markdown_inline",
  "lua", "vim", "vimdoc", "query",
  "make", "cmake",
  "json", "yaml", "toml",
  "diff", "gitcommit", "gitignore",
  "dockerfile", "regex",
  "printf",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    opts = {},
    config = function()
      require("nvim-treesitter").setup({})

      -- Install any missing parsers (diff so we don't reinstall every startup).
      local installed = require("nvim-treesitter.config").get_installed()
      local to_install = vim.iter(ensure_installed)
          :filter(function(p)
            return not vim.tbl_contains(installed, p)
          end)
          :totable()
      if #to_install > 0 then
        require("nvim-treesitter").install(to_install)
      end

      -- Enable highlighting + indentation per-buffer. On the main branch you
      -- start treesitter yourself; a failed start (no parser yet) is non-fatal.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter_start", { clear = true }),
        callback = function(ev)
          local ft = ev.match
          -- Skip markdown highlighting: the 0.12 markdown parser query still
          -- crashes on conceal_lines. Markdown falls back to Vim regex syntax.
          if ft == "markdown" or ft == "markdown_inline" then
            return
          end
          local ok = pcall(vim.treesitter.start)
          if ok then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  -- Text objects (main branch). Provides the select/move/swap queries; we map
  -- the keys ourselves since the module keymap system is gone on main.
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local sel = require("nvim-treesitter-textobjects.select").select_textobject
      local move = require("nvim-treesitter-textobjects.move")
      local swap = require("nvim-treesitter-textobjects.swap")
      local map = vim.keymap.set

      -- Select
      local function s(lhs, q, desc)
        map({ "x", "o" }, lhs, function() sel(q, "textobjects") end, { desc = desc })
      end
      s("af", "@function.outer", "Select outer function")
      s("if", "@function.inner", "Select inner function")
      s("ac", "@class.outer", "Select outer class/struct")
      s("ic", "@class.inner", "Select inner class/struct")
      s("aa", "@parameter.outer", "Select outer argument")
      s("ia", "@parameter.inner", "Select inner argument")
      s("al", "@loop.outer", "Select outer loop")
      s("il", "@loop.inner", "Select inner loop")
      s("ai", "@conditional.outer", "Select outer conditional")
      s("ii", "@conditional.inner", "Select inner conditional")

      -- Move
      map({ "n", "x", "o" }, "]f", function() move.goto_next_start("@function.outer", "textobjects") end,
        { desc = "Next function start" })
      map({ "n", "x", "o" }, "]c", function() move.goto_next_start("@class.outer", "textobjects") end,
        { desc = "Next class start" })
      map({ "n", "x", "o" }, "[f", function() move.goto_previous_start("@function.outer", "textobjects") end,
        { desc = "Previous function start" })
      map({ "n", "x", "o" }, "[c", function() move.goto_previous_start("@class.outer", "textobjects") end,
        { desc = "Previous class start" })

      -- Swap (under <leader>c code group to keep <leader>s = splits)
      map("n", "<leader>ca", function() swap.swap_next("@parameter.inner") end, { desc = "Swap argument right" })
      map("n", "<leader>cA", function() swap.swap_previous("@parameter.inner") end, { desc = "Swap argument left" })
    end,
  },

  -- Sticky function/scope header at top of window
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = { max_lines = 3 },
    keys = {
      { "<leader>tc", "<cmd>TSContextToggle<CR>", desc = "Toggle treesitter context" },
    },
  },
}

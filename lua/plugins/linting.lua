-- ============================================================================
-- Linting: nvim-lint (complements LSP diagnostics)
--   C        -> diagnostics come from clangd + clang-tidy (no extra linter)
--   Python   -> diagnostics come from ruff LSP + basedpyright (no extra linter)
--   Shell    -> shellcheck (also surfaced by bashls; kept for zsh files)
--   Markdown -> markdownlint
--   Everything -> codespell (catches typos in comments/strings)
-- ============================================================================

return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile", "BufWritePost" },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        zsh = { "shellcheck" },
        markdown = { "markdownlint" },
        cmake = { "cmakelint" },
      }

      -- markdownlint: relax rules that fight prettier / real-world docs
      local markdownlint = lint.linters.markdownlint
      markdownlint.args = {
        "--disable", "MD013", -- line length
        "--disable", "MD033", -- inline HTML
        "--",
      }

      local lint_group = vim.api.nvim_create_augroup("user_lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_group,
        callback = function()
          if not vim.bo.modifiable then
            return
          end
          -- Only run linters whose binary is actually installed, so a
          -- not-yet-installed tool (e.g. codespell mid-Mason-install) never
          -- throws "ENOENT: no such file or directory".
          local names = lint.linters_by_ft[vim.bo.filetype] or {}
          local to_run = {}
          for _, name in ipairs(names) do
            local linter = lint.linters[name]
            local cmd = type(linter) == "table" and linter.cmd or nil
            if cmd and vim.fn.executable(cmd) == 1 then
              table.insert(to_run, name)
            end
          end
          -- codespell on every filetype, but only if installed
          if vim.fn.executable("codespell") == 1 then
            table.insert(to_run, "codespell")
          end
          if #to_run > 0 then
            lint.try_lint(to_run)
          end
        end,
      })

      vim.keymap.set("n", "<leader>cl", function()
        lint.try_lint()
      end, { desc = "Trigger linting" })
    end,
  },
}

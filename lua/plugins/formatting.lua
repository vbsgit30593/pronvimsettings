-- ============================================================================
-- Formatting: conform.nvim
--   C        -> clang-format (respects project .clang-format)
--   Python   -> ruff (organize imports + format, black-compatible)
--   Shell    -> shfmt
--   Markdown -> prettier + markdownlint fixes
--   Lua      -> stylua
-- Format-on-save is ON; toggle per-buffer/globally with <leader>tf / <leader>tF
-- ============================================================================

return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = { "n", "v" },
        desc = "Format buffer/selection",
      },
      {
        "<leader>tf",
        function()
          vim.b.disable_autoformat = not vim.b.disable_autoformat
          vim.notify("Format on save (buffer): " .. (vim.b.disable_autoformat and "off" or "on"))
        end,
        desc = "Toggle format-on-save (buffer)",
      },
      {
        "<leader>tF",
        function()
          vim.g.disable_autoformat = not vim.g.disable_autoformat
          vim.notify("Format on save (global): " .. (vim.g.disable_autoformat and "off" or "on"))
        end,
        desc = "Toggle format-on-save (global)",
      },
    },
    opts = {
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
        python = { "ruff_organize_imports", "ruff_format" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
        markdown = { "prettier", "markdownlint" },
        lua = { "stylua" },
        json = { "prettier" },
        jsonc = { "prettier" },
        yaml = { "prettier" },
        toml = { "taplo" },
        -- Trim trailing whitespace everywhere else
        ["_"] = { "trim_whitespace" },
      },
      formatters = {
        ruff_format = {
          -- Enforce 90-char lines. Note: this CLI flag OVERRIDES any
          -- line-length set in a project's pyproject.toml/ruff.toml.
          -- Delete this block if you want project config to win instead.
          prepend_args = { "--line-length", "90" },
        },
        shfmt = {
          prepend_args = { "-i", "2", "-ci", "-bn" }, -- 2-space indent, indent case, binary ops on next line
        },
        ["clang-format"] = {
          -- Only used when the project has no .clang-format file
          prepend_args = { "--fallback-style=LLVM" },
        },
      },
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        -- Never auto-format C/C++ on save (format manually with <leader>cf)
        local ft = vim.bo[bufnr].filetype
        if ft == "c" or ft == "cpp" then
          return
        end
        return { timeout_ms = 2000, lsp_format = "fallback" }
      end,
    },
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()" -- gq uses conform
    end,
  },
}

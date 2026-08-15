-- ============================================================================
-- Markdown: in-buffer rendering + browser preview + table editing
-- (LSP = marksman, lint = markdownlint, format = prettier — see lsp/lint/format)
-- ============================================================================

return {
  -- Render headings, code blocks, tables, checkboxes inside the buffer.
  -- DISABLED BY DEFAULT: on Neovim 0.12 there's an upstream bug where the
  -- markdown treesitter parser's `(#set! conceal_lines "")` directive calls
  -- `.range()` on a nil node, crashing on any markdown file with fenced code
  -- blocks (the "attempt to call method 'range'" error). This is cosmetic
  -- in-buffer rendering only — not needed for editing. Re-enable (enabled=true)
  -- once you've updated the markdown parser (:TSUpdate markdown markdown_inline)
  -- and confirmed the upstream fix has landed.
  {
    "MeanderingProgrammer/render-markdown.nvim",
    enabled = false,
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      completions = { blink = { enabled = true } }, -- checkbox/callout completions
    },
    keys = {
      { "<leader>tm", "<cmd>RenderMarkdown toggle<CR>", ft = "markdown", desc = "Toggle markdown rendering" },
    },
  },

  -- Live preview in the browser
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    keys = {
      { "<leader>tp", "<cmd>MarkdownPreviewToggle<CR>", ft = "markdown", desc = "Toggle browser preview" },
    },
  },

  -- Table alignment/formatting as you type
  {
    "dhruvasagar/vim-table-mode",
    ft = { "markdown" },
    init = function()
      vim.g.table_mode_corner = "|" -- GitHub-flavored markdown tables
    end,
    keys = {
      { "<leader>tb", "<cmd>TableModeToggle<CR>", ft = "markdown", desc = "Toggle table mode" },
    },
  },
}

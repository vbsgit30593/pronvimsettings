-- ============================================================================
-- Completion: blink.cmp (fast, batteries-included) + snippets
-- ============================================================================

return {
  {
    "saghen/blink.cmp",
    version = "1.*", -- use prebuilt fuzzy-matcher binaries (arm64 macOS supported)
    event = "InsertEnter",
    dependencies = {
      "rafamadriz/friendly-snippets", -- community snippets for c, python, sh, md...
    },
    opts = {
      keymap = {
        preset = "default",
        -- default preset highlights:
        --   <C-y> accept    <C-space> open menu / toggle docs
        --   <C-n>/<C-p> or Up/Down to select
        --   <Tab>/<S-Tab> jump snippet placeholders
        ["<CR>"] = { "accept", "fallback" }, -- also accept with Enter
      },
      appearance = {
        nerd_font_variant = "mono",
      },
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
        ghost_text = { enabled = true },
        menu = {
          draw = {
            treesitter = { "lsp" }, -- highlight completion items with treesitter
          },
        },
      },
      signature = { enabled = true },
      sources = {
        -- default = { "lsp", "path", "snippets", "buffer" },
        default = { "lsp", "path", "buffer" },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },
}

-- ============================================================================
-- LSP: Mason installer + language server setup
--
-- Servers:
--   clangd       -> C/C++ (diagnostics via clangd + clang-tidy)
--   basedpyright -> Python type checking / navigation
--   ruff         -> Python lint diagnostics + code actions (server-side)
--   bashls       -> Shell (integrates shellcheck diagnostics)
--   marksman     -> Markdown navigation / references
--   lua_ls       -> Lua (for editing this config)
--   jsonls/yamlls/taplo -> config-file languages you'll meet in any repo
--   neocmake     -> CMake
-- ============================================================================

return {
  -- Mason core: installs external tools into stdpath("data")/mason
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<CR>", desc = "Open Mason" } },
    build = ":MasonUpdate",
    opts = {
      ui = { border = "rounded" },
    },
  },

  -- Auto-install non-LSP tools (formatters, linters, DAP adapters)
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        -- Formatters
        "clang-format", -- C
        "ruff",         -- Python format + lint
        "stylua",       -- Lua
        "shfmt",        -- Shell
        "prettier",     -- Markdown / JSON / YAML
        -- Linters
        "shellcheck",   -- Shell (also consumed by bashls)
        "markdownlint", -- Markdown
        "codespell",    -- Typos in code/comments, all filetypes
        "cmakelint",    -- CMake
        -- Debug adapters
        "codelldb",     -- C (native, works on Apple Silicon)
        "debugpy",      -- Python
      },
      run_on_start = true,
    },
  },

  -- Bridge Mason <-> lsp; auto-enables installed servers (mason-lspconfig v2)
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
      "saghen/blink.cmp",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- ------------------------------------------------------------------
      -- Per-server configuration (merged into nvim-lspconfig defaults
      -- via the vim.lsp.config API, Neovim 0.11+)
      -- ------------------------------------------------------------------

      -- clangd: C/C++
      -- Cross-machine note: if your compile_commands.json is generated on a
      -- build server, keep a .clangd file at the project root to fix the
      -- compiler/sysroot/flags, and rewrite the absolute source paths at copy
      -- time (see examples/fix-compile-commands.sh). To point clangd at a db
      -- that lives outside the project root, set $CLANGD_COMPILE_COMMANDS_DIR.
      local clangd_cmd = {
        "clangd",
        "--background-index",      -- index whole project in background
        "--clang-tidy",            -- run clang-tidy checks inline
        "--header-insertion=iwyu", -- include-what-you-use style inserts
        "--completion-style=detailed",
        -- "--function-arg-placeholders",
        "--fallback-style=llvm",
        "--all-scopes-completion",
        "--pch-storage=memory",
      }
      local ccdir = vim.env.CLANGD_COMPILE_COMMANDS_DIR
      if ccdir and ccdir ~= "" then
        table.insert(clangd_cmd, "--compile-commands-dir=" .. ccdir)
      end

      vim.lsp.config("clangd", {
        cmd = clangd_cmd,
        -- Root detection: compile_commands.json is the source of truth.
        -- Generate it with CMake (-DCMAKE_EXPORT_COMPILE_COMMANDS=ON) or bear.
        root_markers = {
          "compile_commands.json",
          "compile_flags.txt",
          ".clangd",
          ".clang-tidy",
          ".clang-format",
          "configure.ac",
          ".git",
        },
        capabilities = {
          offsetEncoding = { "utf-16" },
          textDocument = {
            completion = {
              editsNearCursor = true,
              completionItem = { snippetSupport = false },
            },
          },
        },
      })

      -- basedpyright: Python types + navigation (community-maintained pyright fork)
      vim.lsp.config("basedpyright", {
        settings = {
          basedpyright = {
            analysis = {
              autoImportCompletions = true,
              autoSearchPaths = true,
              diagnosticMode = "openFilesOnly",
              useLibraryCodeForTypes = true,
              typeCheckingMode = "standard", -- "off" | "basic" | "standard" | "strict"
            },
            -- Ruff handles import organization; avoid duplicate code actions
            disableOrganizeImports = true,
          },
        },
      })

      -- ruff LSP: lint diagnostics + fixes; formatting is routed through conform
      -- NOTE: a project-level pyproject.toml/ruff.toml overrides this editor default
      vim.lsp.config("ruff", {
        init_options = {
          settings = {
            lineLength = 90,
          },
        },
      })

      -- bash-language-server: shell scripts (wires in shellcheck + shfmt)
      vim.lsp.config("bashls", {
        filetypes = { "sh", "bash", "zsh" },
        settings = {
          bashIde = {
            shellcheckPath = vim.fn.stdpath("data") .. "/mason/bin/shellcheck",
          },
        },
      })

      -- lua_ls: for hacking on this config
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            completion = { callSnippet = "Replace" },
            diagnostics = { globals = { "vim" } },
            hint = { enable = true },
          },
        },
      })

      -- yamlls: schema-aware YAML
      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            schemaStore = { enable = true, url = "https://www.schemastore.org/api/json/catalog.json" },
            keyOrdering = false,
          },
        },
      })

      -- ------------------------------------------------------------------
      -- Mason-lspconfig: install and enable servers
      -- ------------------------------------------------------------------
      require("mason-lspconfig").setup({
        ensure_installed = {
          "clangd",
          "basedpyright",
          "ruff",
          "bashls",
          "marksman",
          "lua_ls",
          "jsonls",
          "yamlls",
          "taplo",               -- TOML (pyproject.toml)
          "neocmake",            -- CMake
        },
        automatic_enable = true, -- calls vim.lsp.enable() for installed servers
      })

      -- ------------------------------------------------------------------
      -- Buffer-local keymaps + capabilities on attach
      -- ------------------------------------------------------------------
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          local buf = ev.buf
          local function bmap(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
          end

          -- Navigation.
          -- Navigation. gd/gD use native handlers (instant single jumps);
          -- references/impl/type/symbols use fzf-lua (Telescope removed —
          -- it crashed on the treesitter main branch via ft_to_lang).
          bmap("n", "gd", vim.lsp.buf.definition, "Goto definition")
          bmap("n", "gD", vim.lsp.buf.declaration, "Goto declaration")
          bmap("n", "gr", function() require("fzf-lua").lsp_references() end, "Goto references")
          bmap("n", "gR", function() require("fzf-lua").lsp_references() end, "Goto references")
          bmap("n", "gI", function() require("fzf-lua").lsp_implementations() end, "Goto implementation")
          bmap("n", "gy", function() require("fzf-lua").lsp_typedefs() end, "Goto type definition")
          bmap("n", "<leader>fo", function() require("fzf-lua").lsp_document_symbols() end, "Document symbols (outline)")
          bmap("n", "<leader>fO", function() require("fzf-lua").lsp_live_workspace_symbols() end, "Workspace symbols")

          -- Info / actions (josean uses <leader>rn rename, <leader>ca code action)
          bmap("n", "K", function() vim.lsp.buf.hover({ border = "rounded" }) end, "Hover documentation")
          bmap({ "n", "i" }, "<C-s>", function() vim.lsp.buf.signature_help({ border = "rounded" }) end, "Signature help")
          bmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          bmap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
          bmap("n", "<leader>rs", "<cmd>LspRestart<CR>", "Restart LSP")

          -- clangd extras
          if client and client.name == "clangd" then
            bmap("n", "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<CR>", "Switch source/header (.c <-> .h)")
          end

          -- Inlay hints (types/params rendered inline); toggle with <leader>th
          if client and client:supports_method("textDocument/inlayHint") then
            bmap("n", "<leader>th", function()
              local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = buf })
              vim.lsp.inlay_hint.enable(not enabled, { bufnr = buf })
            end, "Toggle inlay hints")
          end

          -- Highlight other references of symbol under cursor
          if client and client:supports_method("textDocument/documentHighlight") then
            local hl_group = vim.api.nvim_create_augroup("user_lsp_highlight_" .. buf, { clear = true })
            -- Only request highlights for buffers backed by a real file. On
            -- [No Name] / scratch buffers there's no URI, and clangd rejects the
            -- request with "-32602 unresolvable URI".
            local function highlight_if_named()
              if vim.api.nvim_buf_get_name(0) ~= "" then
                vim.lsp.buf.document_highlight()
              end
            end
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              group = hl_group,
              buffer = buf,
              callback = highlight_if_named,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              group = hl_group,
              buffer = buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })
    end,
  },

  -- nvim-lspconfig provides the base server definitions
  { "neovim/nvim-lspconfig" },

  -- SchemaStore for jsonls/yamlls
  { "b0o/schemastore.nvim", lazy = true },
}

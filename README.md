# Neovim Config — C / Python / Markdown / Shell

A production-oriented, Lua-based Neovim configuration using **lazy.nvim** (plugins) and **Mason** (LSP servers, formatters, linters, debug adapters). Built for **macOS on Apple Silicon**, Neovim **0.11+**.

## 1. Prerequisites (Homebrew)

```sh
# Xcode command line tools (compilers, make — needed by telescope-fzf-native and treesitter)
xcode-select --install

# Homebrew packages
brew install neovim git ripgrep fd node python@3.12 llvm shellcheck shfmt

# A Nerd Font for icons (then set it in your terminal, e.g. iTerm2/Ghostty/kitty)
brew install --cask font-jetbrains-mono-nerd-font
```

Notes:

- `ripgrep` and `fd` power Telescope's live grep and file finding — required.
- `node` is needed by several Mason packages (bash-language-server, markdown-preview, prettier).
- Apple's system clang works fine for building; clangd itself is installed by Mason.
- Mason installs its own copies of shellcheck/shfmt too; the brew ones are handy for CI parity.

## 2. Install the config

```sh
# Back up any existing config
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null
mv ~/.local/share/nvim ~/.local/share/nvim.bak 2>/dev/null
mv ~/.local/state/nvim ~/.local/state/nvim.bak 2>/dev/null

# Unzip / copy this directory to ~/.config/nvim so that init.lua is at:
#   ~/.config/nvim/init.lua
cp -r nvim-config ~/.config/nvim
```

First launch:

```sh
nvim
```

lazy.nvim bootstraps itself, installs all plugins, then Mason installs every server/tool (watch `:Mason` — give it a minute on first run). Restart Neovim once everything finishes, then run `:checkhealth` and fix anything red.

## 3. What's configured per language

| | LSP | Formatter | Linter/diagnostics | Debugger |
|---|---|---|---|---|
| **C** | clangd (+ clang-tidy, background index, iwyu headers) | clang-format | clangd + clang-tidy | codelldb |
| **Python** | basedpyright + ruff server | ruff (format + import sort) | ruff + basedpyright | debugpy |
| **Shell** | bash-language-server | shfmt | shellcheck | — |
| **Markdown** | marksman | prettier + markdownlint --fix | markdownlint | — |
| **Lua** | lua_ls | stylua | lua_ls | — |
| **JSON/YAML/TOML/CMake** | jsonls / yamlls / taplo / neocmake | prettier / taplo | cmakelint | — |

`codespell` additionally runs on every filetype to catch typos in comments and strings. Format-on-save is enabled (toggle: `<leader>tf` buffer, `<leader>tF` global).

## 4. Critical for C projects: compile_commands.json

clangd needs a compilation database to understand your project:

```sh
# CMake
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
ln -s build/compile_commands.json .

# Make-based projects
brew install bear
bear -- make
```

Without it, clangd falls back to heuristics and you'll get false errors on includes. Project style: drop a `.clang-format` and `.clang-tidy` in the repo root — both are picked up automatically.

### Using a compile_commands.json generated on a build server

If you build on a Linux server and copy the database to your Mac, the file
contains that server's absolute paths, compiler, and system-include flags —
clangd on macOS can't use them as-is. Fix it in three parts:

1. **Rewrite the source paths.** The `directory`/`file` entries point at the
   server checkout (`/home/you/...`). Rewrite them to your Mac checkout
   (`/Users/you/...`) each time you copy the file down:

   ```sh
   brew install jq
   # edit SERVER_ROOT / LOCAL_ROOT inside the script first
   ./examples/fix-compile-commands.sh compile_commands.json
   ```

2. **Fix compiler/sysroot/flags.** Put a `.clangd` file at your project root
   (template: `examples/dot-clangd-cross-machine`). It swaps the Linux `gcc`
   for local `clang`, points at the macOS SDK, and strips GCC-only flags that
   would otherwise show up as "unknown argument" errors.

3. **(Optional) database outside the project root.** If you keep the synced
   db somewhere other than the repo root, tell clangd where it is:

   ```sh
   export CLANGD_COMPILE_COMMANDS_DIR="$HOME/project/build"
   nvim   # this config passes it to clangd automatically
   ```

Verify it's working: open a `.c` file, run `:LspInfo` (clangd attached), then
`gd` on a symbol should jump correctly. `:checkhealth vim.lsp` and clangd's
own log (`:LspLog`) surface path/flag mismatches if navigation is still off.

## 5. Python projects

basedpyright and ruff pick up the interpreter/config from your project:

- Activate your venv **before** launching nvim (`source .venv/bin/activate`), or
- Add a `pyrightconfig.json` / `[tool.basedpyright]` in `pyproject.toml` pointing at the venv.
- Ruff reads `pyproject.toml` / `ruff.toml` — project config always wins over editor defaults.

## 6. Key bindings cheat sheet (leader = Space)

Press `<Space>` and wait — **which-key** shows everything. Highlights:

### Find / navigate
| Key | Action |
|---|---|
| `<leader>ff` / `fs` / `fc` | Find files / live grep / grep string under cursor |
| `<leader>fr` | Recent files |
| `<leader><leader>` | Switch buffers |
| `<leader>fo` / `fO` | Document / workspace symbols |
| `s` | Flash jump anywhere on screen |
| `-` | Oil (edit directory as a buffer) |
| `<leader>n` | File tree (neo-tree) |
| `<leader>a` / `<leader>h` / `⌥1-4` | Harpoon add / menu / jump |

### Code (LSP)
| Key | Action |
|---|---|
| `gd` / `gr` / `gR` / `gI` / `gy` | Definition / references / references / implementation / type |
| `K` / `<C-s>` | Hover docs / signature help |
| `<leader>cr` / `cc` / `cf` | Rename / code action / format |
| `<leader>ch` | Switch between `.c` and `.h` (clangd) |
| `[d` / `]d`, `<leader>xx` | Prev/next diagnostic, Trouble panel |
| `<leader>th` | Toggle inlay hints |

### Git
| Key | Action |
|---|---|
| `<leader>gg` | Neogit (stage/commit/push UI) |
| `[h` / `]h`, `<leader>gh` / `gr` / `gp` | Hunk navigation / stage / reset / preview |
| `<leader>gv` / `gf` | Diffview / file history |
| `<leader>gb` | Toggle inline blame |

### Debug
| Key | Action |
|---|---|
| `<leader>db` / `dB` | Breakpoint / conditional breakpoint |
| `<leader>dc` / `di` / `do` / `dO` | Continue / step into / over / out |
| `<leader>du` / `de` | Toggle DAP UI / evaluate expression |

### Markdown
| Key | Action |
|---|---|
| `<leader>tm` | Toggle in-buffer rendering |
| `<leader>tp` | Browser live preview |
| `<leader>tb` | Table mode |

### Misc
`<C-\>` terminal · `<leader>u` undo tree · `<leader>j` split/join block · `gcc` comment line · `<leader>ts` restore session

## 7. Maintenance

- `:Lazy` — plugin manager UI (`U` to update)
- `:Mason` — tool installer UI
- `:ConformInfo` — see which formatter applies to the current buffer
- `:LspInfo` — attached servers
- `:checkhealth` — diagnose anything broken

## Layout

```
~/.config/nvim/
├── init.lua
└── lua/
    ├── config/
    │   ├── options.lua      # editor settings + diagnostics UI
    │   ├── keymaps.lua      # global maps
    │   ├── autocmds.lua     # per-filetype behavior
    │   └── lazy.lua         # plugin manager bootstrap
    └── plugins/
        ├── lsp.lua          # Mason + language servers
        ├── completion.lua   # blink.cmp + snippets
        ├── formatting.lua   # conform.nvim
        ├── linting.lua      # nvim-lint
        ├── treesitter.lua   # highlighting + textobjects
        ├── telescope.lua    # fuzzy finding
        ├── navigation.lua   # neo-tree, oil, flash, harpoon, trouble
        ├── git.lua          # gitsigns, diffview, neogit
        ├── debug.lua        # nvim-dap (codelldb, debugpy)
        ├── editing.lua      # autopairs, surround, terminal...
        ├── markdown.lua     # rendering + preview + tables
        └── ui.lua           # colorscheme, statusline, which-key
```

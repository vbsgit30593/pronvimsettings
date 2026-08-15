-- ============================================================================
-- Core editor options
-- ============================================================================
vim.opt.background = "dark"

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

-- Tell Neovim the terminal background explicitly so it doesn't query the
-- terminal for it (avoids the E1568 "terminal did not respond to DSR request"
-- warning on terminals that don't reply, common over SSH / tmux). Set to
-- "light" if you use a light terminal theme.
opt.background = "dark"

-- UI
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes" -- always show, avoids text shifting
opt.cursorline = true
opt.termguicolors = true
opt.showmode = false      -- lualine shows the mode
opt.laststatus = 3        -- global statusline
opt.winborder = "rounded" -- rounded borders for floating windows (0.11+)
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.colorcolumn = "100"
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.fillchars = { eob = " " }

-- Indentation (defaults; per-filetype overrides in autocmds.lua)
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true
opt.breakindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split" -- live preview for :substitute

-- Files / undo
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("state") .. "/undo"
opt.autoread = true

-- Behavior
opt.mouse = "a"
opt.clipboard = "unnamedplus" -- use macOS system clipboard
opt.splitright = true
opt.splitbelow = true
opt.updatetime = 250 -- faster CursorHold / gitsigns
opt.timeoutlen = 400 -- which-key pops up faster
opt.confirm = true   -- confirm instead of failing on unsaved changes
opt.completeopt = { "menu", "menuone", "noselect" }
opt.shortmess:append("c")
opt.pumheight = 12

-- Folding (treesitter-driven, open by default)
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.foldlevelstart = 99

-- Session options (for persistence.nvim)
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }

-- Diagnostics presentation
vim.diagnostic.config({
  severity_sort = true,
  float = { border = "rounded", source = true },
  underline = true,
  update_in_insert = false,
  virtual_text = {
    spacing = 2,
    prefix = "●",
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = "󰌵 ",
    },
  },
})

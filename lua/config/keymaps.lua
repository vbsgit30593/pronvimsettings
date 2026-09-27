-- ============================================================================
-- Global keymaps — josean-style scheme (leader = <Space>)
-- Plugin-specific maps live in their plugin specs.
-- (mapleader/maplocalleader are set in config/options.lua, which loads first.)
-- ============================================================================

local keymap = vim.keymap

-- Exit insert mode with jk (josean's staple)
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- Clear search highlights
keymap.set("n", "<leader>nh", "<cmd>nohl<CR>", { desc = "Clear search highlights" })

-- Increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- ---------------------------------------------------------------------------
-- Window / split management
-- ---------------------------------------------------------------------------
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- ---------------------------------------------------------------------------
-- Tab management
-- ---------------------------------------------------------------------------
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

-- ---------------------------------------------------------------------------
-- Window navigation (also handled by vim-tmux-navigator if you use tmux)
-- ---------------------------------------------------------------------------
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- ---------------------------------------------------------------------------
-- Extras carried over (non-josean but useful, non-conflicting)
-- ---------------------------------------------------------------------------
-- Move selected lines up/down
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
-- Keep selection when indenting
keymap.set("v", "<", "<gv", { desc = "Indent left" })
keymap.set("v", ">", ">gv", { desc = "Indent right" })
-- Center on half-page jumps and search results
keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
keymap.set("n", "n", "nzzzv", { desc = "Next match (centered)" })
keymap.set("n", "N", "Nzzzv", { desc = "Previous match (centered)" })
-- Paste over selection without clobbering the register
keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })
-- Save / quit  (<leader>w is the session prefix, so save lives on <leader>W)
keymap.set("n", "<leader>W", "<cmd>w<CR>", { desc = "Write/save file" })
keymap.set("n", "<leader>q", "<cmd>confirm q<CR>", { desc = "Quit window" })

-- Diagnostics (native)
keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic under cursor" })
keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Previous diagnostic" })
keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })

-- ============================================================================
-- Autocommands
-- ============================================================================

local augroup = function(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

-- Highlight yanked text briefly
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.hl.on_yank({ timeout = 150 })
  end,
})

-- Restore cursor to last position when reopening a file
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_position"),
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local lcount = vim.api.nvim_buf_line_count(ev.buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Per-filetype indentation
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("indent_2"),
  pattern = { "lua", "sh", "bash", "zsh", "markdown", "yaml", "json", "toml", "cmake" },
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
  end,
})

-- C: kernel-ish defaults; adjust to your team's style (clang-format wins anyway)
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("c_settings"),
  pattern = { "c", "cpp" },
  callback = function()
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.commentstring = "// %s"
    vim.opt_local.colorcolumn = "100"
  end,
})

-- Python: PEP 8
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("python_settings"),
  pattern = "python",
  callback = function()
    vim.bo.shiftwidth = 4
    vim.opt_local.colorcolumn = "90" -- matches ruff line-length setting
  end,
})

-- Markdown: prose-friendly
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("markdown_settings"),
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
    vim.opt_local.conceallevel = 2
  end,
})

-- Close some utility windows with just `q`
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = { "help", "man", "qf", "checkhealth", "lspinfo", "startuptime" },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = ev.buf, silent = true })
  end,
})

-- Auto-create missing parent directories on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("auto_mkdir"),
  callback = function(ev)
    if ev.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local dir = vim.fn.fnamemodify(ev.match, ":p:h")
    vim.fn.mkdir(dir, "p")
  end,
})

-- Make shell scripts executable on save if they have a shebang
vim.api.nvim_create_autocmd("BufWritePost", {
  group = augroup("chmod_exec"),
  pattern = { "*.sh" },
  callback = function(ev)
    local first_line = vim.api.nvim_buf_get_lines(ev.buf, 0, 1, false)[1] or ""
    if first_line:match("^#!") then
      vim.fn.system({ "chmod", "+x", ev.file })
    end
  end,
})

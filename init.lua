require("vsingh.core")
require("vsingh.lazy")
vim.cmd([[
  autocmd BufWritePost *.c,*.h silent! !ctags -R /Users/vsingh/nis2/nsagent/mibmgr/aed/
]])

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.py",
    callback = function()
        vim.lsp.buf.format({
            filter = function(client)
                return client.name == "ruff"
            end,
            async = false,
        })
    end,
})

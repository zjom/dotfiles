------ opts
vim.opt_local.spell = true
vim.opt_local.signcolumn = "no"
vim.g.markdown_fenced_languages = { "javascript", "typescript", "bash", "lua", "go", "rust", "c", "cpp" }

local map = function(mode, keys, func, desc)
	vim.keymap.set(mode, keys, func, { buffer = true, desc = "Go: " .. desc })
end

map("n", "<leader>tp", ":RenderMarkdown toggle<enter>", "[T]oggle [P]review")

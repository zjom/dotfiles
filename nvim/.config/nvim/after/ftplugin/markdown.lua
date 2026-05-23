------ opts
vim.opt_local.spell = true
vim.opt_local.signcolumn = "no"
vim.g.markdown_fenced_languages =
	{ "javascript", "typescript", "bash", "lua", "go", "rust", "c", "cpp", "python", "typst" }
vim.o.conceallevel = 0

vim.keymap.set("n", "<C-k>", "z=", { desc = "Spell Suggest", buffer = true })

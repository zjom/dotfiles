------ opts
vim.opt_local.spell = true
vim.opt_local.signcolumn = "no"
vim.g.markdown_fenced_languages = { "javascript", "typescript", "bash", "lua", "go", "rust", "c", "cpp" }

------ keymaps

local map = function(mode, keys, func, desc)
	vim.keymap.set(mode, keys, func, { buffer = true, desc = "Markdown: " .. desc })
end

map("n", "<C-k>", "z=", "Spell Suggest")

map("n", "<leader>tp", ":PencilToggle<cr>", "[T]oggle [P]encil")

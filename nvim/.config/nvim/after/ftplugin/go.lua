local map = function(mode, keys, func, desc)
	vim.keymap.set(mode, keys, func, { buffer = true, desc = "Go: " .. desc })
end

-- local ag = vim.api.nvim_create_augroup("Go", { clear = true })

map("n", "<leader>ct", ":GoTestFile<enter>", "[C]ode [T]est")

map("n", "<leader>cf", ":GoFillStruct<enter>", "[C]ode [F]ill Struct")

map("n", "<leader>cae", ":GoIfErr<enter>", "[C]ode [A]dd If [E]rr")
map("n", "<leader>cac", ":GoCmt<enter>", "[C]ode [A]dd [C]omment")
map("n", "<leader>cat", ":GoAddTag<enter>", "[C]ode [A]dd [T]ags")

map("n", "<leader>cp", ":GoFixPlurals<enter>", "[C]ode fix [Plurals]")

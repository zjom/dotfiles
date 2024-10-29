local map = function(mode, keys, func, desc)
	vim.keymap.set(mode, keys, func, { buffer = true, desc = "Go: " .. desc })
end

-- local ag = vim.api.nvim_create_augroup("Go", { clear = true })

map("n", "<leader>ct", ":GoTestFile<enter>", "[C]ode [T]est")
map("n", "<leader>cfs", ":GoFillStruct<enter>", "[C]ode [F]ill [S]truct")
map("n", "<leader>cfS", ":GoFillSwitch<enter>", "[C]ode [F]ill [S]witch")

map("n", "<leader>ce", ":GoIfErr<enter>", "[C]ode insert if [E]rr")
map("n", "<leader>cp", ":GoFixPlurals<enter>", "[C]ode insert if [E]rr")

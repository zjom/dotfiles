vim.pack.add({ "https://github.com/folke/trouble.nvim" })
require("trouble").setup()
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", {
	desc = "[X]oggle Diagnostics (Trouble)",
})
vim.keymap.set("n", "<leader>xl", "<cmd>Trouble loclist toggle<cr>", {
	desc = "[X]oggle [L]oclist (Trouble)",
})
vim.keymap.set("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", {
	desc = "[X]oggle [Q]uickfix List (Trouble)",
})
vim.keymap.set("n", "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", {
	desc = "[C]ode [S]ymbols (Trouble)",
})
vim.keymap.set("n", "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", {
	desc = "[C]ode [L]SP Definitions / references / ... (Trouble)",
})

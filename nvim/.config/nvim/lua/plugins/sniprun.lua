return {
	"michaelb/sniprun",
	run = "bash ./install.sh",

	vim.keymap.set("n", "<Leader>cr", ":SnipRun<CR>", { desc = "[C]ode [R]un", silent = true }),
	vim.keymap.set("v", "<Leader>cr", ":SnipRun<CR>", { desc = "[C]ode [R]un", silent = true }),
}

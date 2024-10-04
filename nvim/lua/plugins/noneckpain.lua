return {
	"shortcuts/no-neck-pain.nvim",
	version = "*",
	vim.keymap.set("n", "<leader>bf", ":NoNeckPain<cr>", { desc = "[B]uffer [F]ocus" }),
}

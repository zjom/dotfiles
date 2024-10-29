return {
	"shortcuts/no-neck-pain.nvim",
	version = "*",
	vim.keymap.set("n", "<leader>tf", ":NoNeckPain<cr>", { desc = "[T]oggle [F]ocus" }),
}

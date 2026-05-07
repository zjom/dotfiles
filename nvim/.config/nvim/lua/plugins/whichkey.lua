vim.pack.add({ "https://github.com/folke/which-key.nvim" })
require("which-key").setup({
	-- Document existing key chains
	spec = {
		{ "<leader>b", group = "[B]uffer" },
		{ "<leader>c", group = "[C]ode" },
		{ "<leader>d", group = "[D]ap" },
		{ "<leader>o", group = "[O]rg" },
		{ "<leader>r", group = "[R]equest" },
		{ "<leader><C-R>", group = "[R]estart" },
		{ "<leader>s", group = "[S]earch" },
		{ "<leader>w", group = "[W]orkspace" },
		{ "<leader>x", group = "[X]oggle" },
		{ "<leader>t", group = "[T]ab" },
		{ "<leader>o", group = "[O]rg" },
	},
})

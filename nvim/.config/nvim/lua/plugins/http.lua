return {
	"mistweaverco/kulala.nvim",
	keys = {
		{ "<leader>Rj", desc = "Send request", ft = { "http", "rest" } },
		{ "<leader>Ra", desc = "Send all requests", ft = { "http", "rest" } },
		{ "<leader>Rb", desc = "Open scratchpad", ft = { "http", "rest" } },
	},
	ft = { "http", "rest" },
	opts = {
		global_keymaps = false,
		global_keymaps_prefix = "<leader>R",
		kulala_keymaps_prefix = "",
	},
}

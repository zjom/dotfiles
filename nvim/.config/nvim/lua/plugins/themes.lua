return {
	{
		"vague2k/vague.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("vague").setup({
				transparent = true,
			})

			vim.cmd("colorscheme vague")
			vim.cmd(":hi statusline guibg=NONE")
		end,
	},
	-- {
	-- 	"ramojus/mellifluous.nvim",
	-- 	name = "mellifluous",
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	config = function()
	-- 		require("mellifluous").setup({
	-- 			transparent = true,
	-- 		})
	--
	-- 		vim.cmd("colorscheme mellifluous")
	-- 		vim.cmd(":hi statusline guibg=NONE")
	-- 	end,
	-- },
	-- {
	-- 	"catppuccin/nvim",
	-- 	name = "catppuccin",
	-- },
	-- {
	-- 	"nuvic/flexoki-nvim",
	-- 	name = "flexoki",
	-- },
	-- {
	-- 	"sainnhe/everforest",
	-- 	config = function()
	-- 		vim.g.everforest_background = "hard"
	-- 		vim.g.everforest_better_performance = 1
	-- 	end,
	-- },
}

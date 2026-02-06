-- Render markdown in neovim
return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
	-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
	-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
	---@module 'render-markdown'
	---@type render.md.UserConfig
	opts = {},
	keys = {

		{
			"<leader>xr",
			"<cmd>RenderMarkdown toggle<cr>",
			ft = "markdown",
			desc = "Toggle [R]ender",
		},
	},
	config = function()
		require("render-markdown").disable()
	end,
}

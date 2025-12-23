return {
	"kristijanhusak/vim-dadbod-ui",
	dependencies = {
		{ "tpope/vim-dadbod",                     lazy = true },
		{ "kristijanhusak/vim-dadbod-completion", ft = { "sql" }, lazy = true }, -- Optional
	},
	cmd = {
		"DBUI",
		"DBUIToggle",
		"DBUIAddConnection",
		"DBUIFindBuffer",
	},
	keys = {
		{
			"<leader>xb",
			"<cmd>DBUIToggle<cr>",
			desc = "Toggle D[B]UI",
		},
	},
	init = function()
		-- Your DBUI configuration
		vim.g.db_ui_use_nerd_fonts = 1
	end,
}

return {
	"ray-x/go.nvim",
	dependencies = { -- optional packages
		"ray-x/guihua.lua",
		"neovim/nvim-lspconfig",
		"nvim-treesitter/nvim-treesitter",
	},
	opts = function()
		require("go").setup()
		local format_sync_grp = vim.api.nvim_create_augroup("zjom-go", {})
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*.go",
			callback = function()
				require("go.format").goimports()
			end,
			group = format_sync_grp,
		})

		return {
			lsp_cfg = false,
		}
	end,
	event = { "CmdlineEnter" },
	ft = { "go", "gomod" },
	keys = {
		{ "<leader>ct", ":GoTestFile<enter>", desc = "[C]ode [T]est" },
		{ "<leader>cae", ":GoIfErr<enter>", desc = "[C]ode [A]dd If [E]rr" },
		{ "<leader>cac", ":GoCmt<enter>", desc = "[C]ode [A]dd [C]omment" },
		{ "<leader>cat", ":GoAddTag<enter>", desc = "[C]ode [A]dd [T]ags" },
		{ "<leader>cp", ":GoFixPlurals<enter>", "[C]ode fix [Plurals]" },
	},
	build = ':lua require("go.install").update_all_sync()',
}

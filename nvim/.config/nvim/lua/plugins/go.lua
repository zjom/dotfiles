-- go.nvim provides useful commands and utilities while working with golang
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

		vim.keymap.set("n", "<leader>ct", ":GoTestFile<enter>", { desc = "[C]ode [T]est" })
		vim.keymap.set("n", "<leader>ce", ":GoIfErr<enter>", { desc = "[C]ode Add If [E]rr" })
		vim.keymap.set("n", "<leader>cac", ":GoCmt<enter>", { desc = "[C]ode [A]dd [C]omment" })
		vim.keymap.set("n", "<leader>ct", ":GoTestFile<enter>", { desc = "[C]ode [T]est" })

		return {
			lsp_cfg = false,
		}
	end,
	ft = { "go", "gomod" },
	keys = {},
	build = ':lua require("go.install").update_all_sync()',
}

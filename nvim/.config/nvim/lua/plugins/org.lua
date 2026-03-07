return {
	"nvim-orgmode/orgmode",
	dependencies = {
		"nvim-orgmode/telescope-orgmode.nvim",
	},
	event = "VeryLazy",
	config = function()
		require("orgmode").setup({
			org_agenda_files = "~/o/**/*",
			org_default_notes_file = "~/o/refile.org",
			org_todo_keywords = { "TODO(t)", "WAITING(w)", "|", "DONE(d)" },
			mappings = {
				org = {
					org_todo = "<C-c>t",
				},
			},
		})
		-- Experimental LSP support
		vim.lsp.enable("org")
	end,
}

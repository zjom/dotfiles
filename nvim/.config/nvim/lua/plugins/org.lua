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
				agenda = {
					org_agenda_day_view = "<leader>vd",
					org_agenda_week_view = "<leader>vw",
					org_agenda_month_view = "<leader>vm",
				},
			},
		})
		-- Experimental LSP support
		vim.lsp.enable("org")
	end,
}

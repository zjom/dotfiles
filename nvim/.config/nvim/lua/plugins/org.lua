return {
	"nvim-orgmode/orgmode",
	event = "VeryLazy",
	config = function()
		require("orgmode").setup({
			org_agenda_files = "~/o/**/*",
			org_default_notes_file = "~/o/refile.org",
			org_todo_keywords = { "TODO(t)", "IDEA(i)", "WAITING(w)", "|", "DONE(d)" },
			org_todo_keyword_faces = {
				TODO = ":foreground red  :weight bold",
				IDEA = ":foreground yellow",
				WAITING = ":foreground pink",
				DONE = ":foreground green",
			},
			mappings = {
				org = {
					org_todo = "<leader>ot",
					org_set_tags_command = "<leader>oT",
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

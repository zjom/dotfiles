vim.pack.add({ "https://github.com/nvim-orgmode/orgmode" })
require("orgmode").setup({
	org_agenda_files = "~/o/**/*",
	org_default_notes_file = "~/o/refile.org",
})
vim.lsp.enable("org")

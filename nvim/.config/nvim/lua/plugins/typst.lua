return {
	"chomosuke/typst-preview.nvim",
	ft = "typst",
	version = "1.*",
	opts = {}, -- lazy.nvim will implicitly calls `setup {}`
	keys = {
		{ "<leader>xp", ":TypstPreviewToggle<enter>", { desc = "Toggle [P]review" }, ft = "typst" },
	},
}

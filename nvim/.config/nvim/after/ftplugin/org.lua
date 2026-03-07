vim.keymap.set(
	"n",
	"<leader>oil",
	require("telescope").extensions.orgmode.insert_link,
	{ desc = "org insert link (telescope)" }
)

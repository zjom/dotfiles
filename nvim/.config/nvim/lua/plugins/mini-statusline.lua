-- Simple and easy statusline.
return {
	"nvim-mini/mini.statusline",
	config = function()
		require("mini.statusline").setup()
	end,
}

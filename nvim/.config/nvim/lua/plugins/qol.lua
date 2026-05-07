-- small quality of life things
local function gh(repo)
	return "https://github.com/" .. repo
end

vim.pack.add({
	gh("nvim-tree/nvim-web-devicons"),
	gh("lewis6991/gitsigns.nvim"),
	gh("windwp/nvim-autopairs"),
	gh("windwp/nvim-ts-autotag"),
	gh("numToStr/Comment.nvim"), -- "gc" to comment visual regions/lines
	gh("christoomey/vim-tmux-navigator"), -- tmux navigation
	gh("folke/todo-comments.nvim"), -- Highlight todo, notes, etc in comments
})
require("nvim-autopairs").setup({})
require("nvim-ts-autotag").setup({})
require("Comment").setup()
require("todo-comments").setup({ signs = true })

require("gitsigns").setup({
	signs = {
		add = { text = "+" },
		change = { text = "~" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
	},
})

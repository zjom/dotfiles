-- Small improvements to daily use.
local function gh(repo)
	return "https://github.com/" .. repo
end

vim.pack.add({
	gh("nvim-tree/nvim-web-devicons"),
	gh("windwp/nvim-autopairs"),
	gh("windwp/nvim-ts-autotag"),
	gh("numToStr/Comment.nvim"), -- "gc" comments visual regions and lines
	gh("christoomey/vim-tmux-navigator"), -- tmux navigation
	gh("folke/todo-comments.nvim"), -- Highlights TODO, NOTE and similar keywords in comments
})
require("nvim-autopairs").setup({})
require("nvim-ts-autotag").setup({})
require("Comment").setup()
require("todo-comments").setup({ signs = true })

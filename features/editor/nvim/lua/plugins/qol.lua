local function gh(repo)
	return "https://github.com/" .. repo
end

vim.pack.add({
	gh("nvim-tree/nvim-web-devicons"),
	gh("windwp/nvim-autopairs"),
	gh("windwp/nvim-ts-autotag"),
	gh("numToStr/Comment.nvim"),
	gh("christoomey/vim-tmux-navigator"),
	gh("folke/todo-comments.nvim"),
})
require("nvim-autopairs").setup({})
require("nvim-ts-autotag").setup({})
require("Comment").setup()
require("todo-comments").setup({ signs = true })

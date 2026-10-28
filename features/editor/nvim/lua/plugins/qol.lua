vim.pack.add({
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/windwp/nvim-autopairs",
	"https://github.com/windwp/nvim-ts-autotag",
	"https://github.com/numToStr/Comment.nvim",
	"https://github.com/christoomey/vim-tmux-navigator",
	"https://github.com/folke/todo-comments.nvim",
})
require("nvim-autopairs").setup({})
require("nvim-ts-autotag").setup({})
require("Comment").setup()
require("todo-comments").setup({ signs = true })

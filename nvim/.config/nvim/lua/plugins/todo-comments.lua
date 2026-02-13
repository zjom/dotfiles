-- Highlight todo, notes, etc in comments
return {
	"folke/todo-comments.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = { signs = true },
	event = "BufWinEnter",
	config = function()
		vim.keymap.set("n", "]t", function()
			require("todo-comments").jump_next()
		end, { desc = "Next [T]odo comment" })

		vim.keymap.set("n", "[t", function()
			require("todo-comments").jump_prev()
		end, { desc = "Previous [T]odo comment" })
	end,
}

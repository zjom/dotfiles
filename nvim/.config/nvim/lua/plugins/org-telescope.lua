return {
	"nvim-orgmode/telescope-orgmode.nvim",
	event = "VeryLazy",
	dependencies = {
		"nvim-orgmode/orgmode",
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		require("telescope").load_extension("orgmode")
		local ext = require("telescope").extensions.orgmode

		vim.keymap.set("n", "<leader>soh", ext.search_headings, { desc = "[S]earch [O]rg [H]eadings" })
		vim.keymap.set("n", "<leader>sot", ext.search_tags, { desc = "[S]earch [O]rg [T]ags" })
		vim.keymap.set("n", "<leader>sof", function()
			require("telescope.builtin").find_files({ cwd = "~/o/" })
		end, { desc = "[S]earch [O]rg [F]iles" })
		vim.keymap.set("n", "<leader>or", ext.refile_heading, { desc = "org refile" })
		vim.keymap.set("n", "<leader>oil", ext.insert_link, { desc = "org insert link (telescope)" })
	end,
}

local telescope_plugins = {
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-telescope/telescope.nvim",
	"https://github.com/nvim-telescope/telescope-ui-select.nvim",
}
if vim.fn.executable("make") == 1 then
	table.insert(telescope_plugins, "https://github.com/nvim-telescope/telescope-fzf-native.nvim")
end

vim.pack.add(telescope_plugins)
require("telescope").setup({
	defaults = {
		file_ignore_patterns = {
			"node_modules",
			"vendor",
			"venv",
			".venv",
		},
	},
	extensions = {
		["ui-select"] = { require("telescope.themes").get_dropdown() },
	},
})

pcall(require("telescope").load_extension, "fzf")
pcall(require("telescope").load_extension, "ui-select")

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "ff", builtin.find_files, { desc = "[F]ind [F]iles" })
vim.keymap.set({ "n", "v" }, "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
vim.keymap.set("n", "<leader>ss", builtin.lsp_document_symbols, { desc = "[S]earch document [S]ymbols" })
vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
vim.keymap.set("n", "<leader>/", function()
	builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
		winblend = 10,
		previewer = false,
	}))
end, { desc = "[/] Fuzzily search in current buffer" })
vim.keymap.set("n", "<leader>s/", function()
	builtin.live_grep({
		grep_open_files = true,
		prompt_title = "Live Grep in Open Files",
	})
end, { desc = "[S]earch [/] in Open Files" })
if vim.g.dotfiles then
	vim.keymap.set("n", "<leader>sc", function()
		builtin.find_files({ cwd = vim.g.dotfiles })
	end, { desc = "[S]earch [C]onfig" })
end
vim.keymap.set("i", "<C-x><C-i>", builtin.symbols, { desc = "[x] [I]nsert Symbols" })

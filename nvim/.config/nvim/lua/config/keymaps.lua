-- Set jk to esc insert
vim.keymap.set("i", "jk", "<Esc>")

-- Remap for dealing with word wrap and adding jumps to the jumplist.
vim.keymap.set("n", "j", [[(v:count > 1 ? 'm`' . v:count : 'g') . 'j']], { expr = true })
vim.keymap.set("n", "k", [[(v:count > 1 ? 'm`' . v:count : 'g') . 'k']], { expr = true })

-- Keeping the cursor centered.
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll downwards" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll upwards" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous result" })

-- Indent while remaining in visual mode.
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Formatting.
vim.keymap.set("n", "gQ", "mzgggqG`z<cmd>delmarks z<cr>zz", { desc = "Format buffer" })

-- Restart Neovim.
vim.keymap.set("n", "<leader>R", "<cmd>restart<cr>", { desc = "Restart Neovim" })

-- Tab navigation.
vim.keymap.set("n", "<leader>tc", "<cmd>tabclose<cr>", { desc = "Close tab page" })
vim.keymap.set("n", "<leader>tn", "<cmd>tab split<cr>", { desc = "New tab page" })
vim.keymap.set("n", "<leader>to", "<cmd>tabonly<cr>", { desc = "Close other tab pages" })

-- Poweful <esc>.
vim.keymap.set({ "i", "s", "n" }, "<esc>", function()
	if require("luasnip").expand_or_jumpable() then
		require("luasnip").unlink_current()
	end
	vim.cmd("noh")
	return "<esc>"
end, { desc = "Escape, clear hlsearch, and stop snippet session", expr = true })

-- Make U opposite to u.
vim.keymap.set("n", "U", "<C-r>", { desc = "Redo" })

-- Escape and save changes.
vim.keymap.set({ "s", "i", "n", "v" }, "<C-s>", "<esc>:w<cr>", { desc = "Exit insert mode and save changes" })
vim.keymap.set({ "s", "i", "n", "v" }, "<C-S-s>", function()
	vim.g.skip_formatting = true
	return "<esc>:w<cr>"
end, { desc = "Exit insert mode and save changes (without formatting)", expr = true })

-- Quickly go to the end of the line while in insert mode.
vim.keymap.set({ "i", "c" }, "<C-l>", "<C-o>A", { desc = "Go to the end of the line" })

-- Mark management.
vim.keymap.set("c", "dm", "delmarks", { desc = "Delete marks" })
-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Buffer navigation
vim.keymap.set("n", "<leader>bp", ":b#<CR>", { desc = "[B]uffer [P]revious", silent = true })
vim.keymap.set("n", "<leader>bn", ":bn<CR>", { desc = "[B]uffer [N]ext", silent = true })
vim.keymap.set("n", "<leader>bd", ":bd<CR>", { desc = "[B]uffer [D]elete current", silent = true })
vim.keymap.set("n", "<leader>bc", ":vs and new_window<CR>", { desc = "[B]uffer [C]reate ", silent = true })

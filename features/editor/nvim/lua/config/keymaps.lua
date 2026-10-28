vim.keymap.set("i", "jk", "<Esc>")

-- Move by screen lines when lines wrap, and add jumps with a count to the
-- jumplist.
vim.keymap.set("n", "j", [[(v:count > 1 ? 'm`' . v:count : 'g') . 'j']], { expr = true })
vim.keymap.set("n", "k", [[(v:count > 1 ? 'm`' . v:count : 'g') . 'k']], { expr = true })

-- Keep the cursor in the center of the window.
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll downwards" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll upwards" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous result" })

-- Indent and stay in visual mode.
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

vim.keymap.set("n", "gQ", "mzgggqG`z<cmd>delmarks z<cr>zz", { desc = "Format buffer" })
vim.keymap.set("n", "<leader>xF", "<cmd>ToggleFormat<cr>", { desc = "[X]oggle Format" })

vim.keymap.set("n", "<leader><C-r><C-r>", "<cmd>restart<cr>", { desc = "[R]estart Neovim" })

vim.keymap.set("n", "<leader>td", "<cmd>tabclose<cr>", { desc = "[D]elete Tab" })
vim.keymap.set("n", "<leader>tc", "<cmd>tabnew<cr>", { desc = "[C]reate Tab" })
vim.keymap.set("n", "<leader>to", "g<Tab>", { desc = "[O]ther Tab" })
vim.keymap.set("n", "<leader>t!", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
vim.keymap.set("n", "<leader>tn", "<cmd>tabNext<cr>", { desc = "[N]ext Tab" })
vim.keymap.set("n", "<leader>t1", "<cmd>tabfirst<cr>", { desc = "First Tab" })
vim.keymap.set("n", "<leader>t9", "<cmd>tablast<cr>", { desc = "Last Tab" })

vim.keymap.set({ "i", "s", "n" }, "<esc>", function()
	if require("luasnip").expand_or_jumpable() then
		require("luasnip").unlink_current()
	end
	vim.cmd("noh")
	return "<esc>"
end, { desc = "Escape, clear hlsearch, and stop snippet session", expr = true })

vim.keymap.set({ "i", "c" }, "<M-BS>", "<C-w>", { desc = "Delete previous word" })
vim.keymap.set("i", "<C-w>", "<Nop>")
vim.keymap.set({ "s", "i", "n", "v" }, "<C-w><C-w>", "", {
	callback = function()
		if vim.fn.getbufvar(vim.fn.bufnr(), "&modified") == 1 then
			vim.cmd("write")
		end
	end,
	desc = "[W]rite file",
})

vim.keymap.set({ "i", "c" }, "<C-l>", "<C-o>A", { desc = "Go to the end of the line" })
vim.keymap.set({ "i", "c" }, "<C-h>", "<C-o>I", { desc = "Go to the start of the line" })
vim.keymap.set({ "i", "c" }, "<C-b>", "<C-o>B", { desc = "Go to start of previous word" })
vim.keymap.set({ "i", "c" }, "<C-e>", "<C-o>e<C-o>l", { desc = "Go to end of next word" })

vim.keymap.set("c", "dm", "delmarks", { desc = "Delete marks" })

-- NOTE: This shortcut does not work in all terminal emulators or in tmux. If
-- the shortcut does not work, use a different mapping or use <C-\><C-n>.
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

vim.keymap.set("n", "<leader>bp", ":b#<CR>", { desc = "[B]uffer [P]revious", silent = true })
vim.keymap.set("n", "<leader>bn", ":bn<CR>", { desc = "[B]uffer [N]ext", silent = true })
vim.keymap.set("n", "<leader>bd", ":bd<CR>", { desc = "[B]uffer [D]elete current", silent = true })
vim.keymap.set("n", "<leader>bc", ":vs and new_window<CR>", { desc = "[B]uffer [C]reate ", silent = true })
vim.keymap.set("n", "<leader>bs", ":Scratch<CR>", { desc = "[B]uffer [Scratch]", silent = true })

vim.keymap.set("n", "<leader>L0", ":set nonu nornu<CR>", { desc = "[L]inenumbers Off", silent = true })
vim.keymap.set("n", "<leader>L1", ":set nu rnu<CR>", { desc = "[L]inenumbers Relative", silent = true })
vim.keymap.set("n", "<leader>L2", ":set nu nornu<CR>", { desc = "[L]inenumbers Normal", silent = true })

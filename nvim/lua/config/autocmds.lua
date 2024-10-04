-- [[ Basic Autocommands ]]
--  See :help lua-guide-autocommands

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Toggle unordered list for selected lines
function ToggleUnorderedList()
	local start_line, end_line = vim.fn.line("'<"), vim.fn.line("'>")
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

	-- Check if the first selected line is already a list item
	local is_list = lines[1]:match("^%s*[-*] ")

	-- Prepare new lines to replace the selected lines
	local new_lines = {}
	for _, line in ipairs(lines) do
		if is_list then
			-- Remove list marker
			local new = line:gsub("^%s*[-*] ", "")
			table.insert(new_lines, new)
		else
			-- Add list marker
			table.insert(new_lines, "- " .. line)
		end
	end

	-- Replace selected lines with the modified lines
	vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, new_lines)
end

-- Toggle ordered list for selected lines
function ToggleOrderedList()
	local start_line, end_line = vim.fn.line("'<"), vim.fn.line("'>")
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

	-- Check if the first selected line is already a numbered list item
	local is_list = lines[1]:match("^%s*%d+%. ")

	-- Prepare new lines to replace the selected lines
	local new_lines = {}
	for i, line in ipairs(lines) do
		if is_list then
			-- Remove list marker
			local new = line:gsub("^%s*%d+%. ", "")
			table.insert(new_lines, new)
		else
			-- Add list marker (i is used for numbering)
			table.insert(new_lines, i .. ". " .. line)
		end
	end

	-- Replace selected lines with the modified lines
	vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, new_lines)
end

-- Markdown
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		-- Turn on spell check
		vim.opt_local.spell = true
		-- Add helper mapping to toggle unordered list in selected lines
		vim.api.nvim_set_keymap("v", "<leader>u", ":lua ToggleUnorderedList()<CR>", { noremap = true, silent = true })
		vim.api.nvim_set_keymap("v", "<leader>o", ":lua ToggleOrderedList()<CR>", { noremap = true, silent = true })
	end,
})

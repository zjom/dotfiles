------ opts
vim.opt_local.spell = true
vim.opt_local.signcolumn = "no"
vim.g.markdown_fenced_languages = { "javascript", "typescript", "bash", "lua", "go", "rust", "c", "cpp" }

------ plugins
-- Prose writing convenience
-- vim.cmd("Pencil")

------ misc
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

-- Conver current file to pdf using pandoc with zotref and crossref filters
function CompileAndOpen()
	vim.cmd("write") -- save current buffer
	local fp = vim.fn.expand("%:p")
	local file_name = fp:match("^.+/(.+)$")

	vim.notify("Exporting " .. file_name .. " to tmp.pdf...")

	vim.fn.jobstart({
		"bash",
		"-c",
		"source ~/py3nvim/bin/activate && pandoc "
			.. fp
			.. " -s -o tmp.pdf -F pandoc-crossref -F ~/.local/share/nvim/lazy/zotcite/python3/zotref.py --citeproc --csl=/Users/zihanjin/zotero/styles/harvard-cite-them-right.csl",
	}, {
		stderr_buffered = true,
		stdout_buffered = true,
		on_stdout = function(_, data)
			if data and #data > 0 then
				local stderr_lines = ""
				for _, line in ipairs(data) do
					stderr_lines = stderr_lines .. "\n" .. line
				end
				vim.notify(stderr_lines)
			end
		end,
		on_stderr = function(_, data)
			if data and #data > 0 then
				-- Prefix stderr lines with "stderr: " to differentiate them
				local stderr_lines = ""
				for _, line in ipairs(data) do
					if line ~= "" and line ~= "\n" then
						stderr_lines = stderr_lines .. "\n" .. line
					end
				end
				vim.notify(stderr_lines, 4)
			end
		end,
		on_exit = function()
			vim.ui.open("tmp.pdf")
		end,
	})
end

------ keymaps

local map = function(mode, keys, func, desc)
	vim.keymap.set(mode, keys, func, { buffer = true, desc = "Markdown: " .. desc })
end
-- Add helper mapping to toggle unordered list in selected lines
map("v", "<leader>u", ToggleUnorderedList, "toggle [U]nordered List")

map("v", "<leader>o", ToggleOrderedList, "toggle [O]nordered List")

map("n", "<leader>bc", CompileAndOpen, "[B]uffer [C]ompile")

map("n", "<C-k>", "z=", "Spell Suggest")

map("n", "<leader>tp", ":PencilToggle<cr>", "[T]oggle [P]encil")

map("n", "<leader>to", require("otter").activate, "[T]oggle [Otter]")

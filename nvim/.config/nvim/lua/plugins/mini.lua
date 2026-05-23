-- [[ mini.nvim ]]
--  A collection of various small independent plugins/modules
vim.pack.add({ "https://github.com/nvim-mini/mini.nvim" })

-- Better Around/Inside textobjects
--
-- Examples:
--  - va)  - [V]isually select [A]round [)]parenthen
--  - yinq - [Y]ank [I]nside [N]ext [']quote
--  - ci'  - [C]hange [I]nside [']quote
require("mini.ai").setup({
	mappings = {
		around_next = "aa",
		inside_next = "ii",
	},
	n_lines = 500,
})

-- Add/delete/replace surroundings (brackets, quotes, etc.)
--
-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
-- - sd'   - [S]urround [D]elete [']quotes
-- - sr)'  - [S]urround [R]eplace [)] [']
require("mini.surround").setup({
	-- Module mappings. Use `''` (empty string) to disable one.
	mappings = {
		add = "gsa", -- Add surrounding in Normal and Visual modes
		delete = "gsd", -- Delete surrounding
		find = "gsf", -- Find surrounding (to the right)
		find_left = "gsF", -- Find surrounding (to the left)
		highlight = "gsh", -- Highlight surrounding
		replace = "gsr", -- Replace surrounding
		update_n_lines = "gsn", -- Update `n_lines`

		suffix_last = "gl", -- Suffix to search with "prev" method
		suffix_next = "gn", -- Suffix to search with "next" method
	},
})

-- Save the window layout when closing a buffer.
vim.keymap.set("n", "<leader>bd", function()
	require("mini.bufremove").delete(0, false)
end, { desc = "[B]uffer [D]elete" })

-- File explorer
local function map_split(buf_id, lhs, direction)
	local minifiles = require("mini.files")

	local function rhs()
		local window = minifiles.get_explorer_state().target_window

		-- Noop if the explorer isn't open or the cursor is on a directory.
		if window == nil or minifiles.get_fs_entry().fs_type == "directory" then
			return
		end

		-- Make a new window and set it as target.
		local new_target_window
		vim.api.nvim_win_call(window, function()
			vim.cmd(direction .. " split")
			new_target_window = vim.api.nvim_get_current_win()
		end)

		minifiles.set_target_window(new_target_window)

		-- Go in and close the explorer.
		minifiles.go_in({ close_on_file = true })
	end

	vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = "Split " .. string.sub(direction, 12) })
end

-- Yank in register full path of entry under cursor
local yank_path = function()
	local path = (require("mini.files").get_fs_entry() or {}).path
	if path == nil then
		return vim.notify("Cursor is not on valid entry")
	end
	vim.fn.setreg(vim.v.register, path)
end

-- Open path with system default handler (useful for non-text files)
local ui_open = function()
	vim.ui.open(require("mini.files").get_fs_entry().path)
end

local show_dotfiles = true

local filter_show = function(_)
	return true
end

local filter_hide = function(fs_entry)
	return not vim.startswith(fs_entry.name, ".")
end

local toggle_dotfiles = function()
	show_dotfiles = not show_dotfiles
	local new_filter = show_dotfiles and filter_show or filter_hide
	require("mini.files").refresh({ content = { filter = new_filter } })
end

local minifiles_toggle = function()
	local minifiles = require("mini.files")
	if not minifiles.close() then
		minifiles.open(vim.api.nvim_buf_get_name(0), true)
	end
end
require("mini.files").setup({
	content = {
		filter = show_dotfiles and filter_show or filter_hide,
		sort = function(entries)
			local function compare_alphanumerically(e1, e2)
				-- Put directories first.
				if e1.is_dir and not e2.is_dir then
					return true
				end
				if not e1.is_dir and e2.is_dir then
					return false
				end
				-- Order numerically based on digits if the text before them is equal.
				if e1.pre_digits == e2.pre_digits and e1.digits ~= nil and e2.digits ~= nil then
					return e1.digits < e2.digits
				end
				-- Otherwise order alphabetically ignoring case.
				return e1.lower_name < e2.lower_name
			end

			local sorted = vim.tbl_map(function(entry)
				local pre_digits, digits = entry.name:match("^(%D*)(%d+)")
				if digits ~= nil then
					digits = tonumber(digits)
				end

				return {
					fs_type = entry.fs_type,
					name = entry.name,
					path = entry.path,
					lower_name = entry.name:lower(),
					is_dir = entry.fs_type == "directory",
					pre_digits = pre_digits,
					digits = digits,
				}
			end, entries)
			table.sort(sorted, compare_alphanumerically)
			-- Keep only the necessary fields.
			return vim.tbl_map(function(x)
				return { name = x.name, fs_type = x.fs_type, path = x.path }
			end, sorted)
		end,
	},
	windows = { width_nofocus = 25 },
	-- Move stuff to the minifiles trash instead of it being gone forever.
	options = { permanent_delete = false },
})

vim.keymap.set("n", "<C-e>", minifiles_toggle, { desc = "Toggle File [E]xplorer" })
vim.keymap.set("n", "<leader>xe", minifiles_toggle, { desc = "Toggle File [E]xplorer" })

-- Keep track of when the explorer is open to disable format on save.
local minifiles_explorer_group = vim.api.nvim_create_augroup("zjom/minifiles_explorer", { clear = true })
vim.api.nvim_create_autocmd("User", {
	group = minifiles_explorer_group,
	pattern = "MiniFilesExplorerOpen",
	callback = function()
		vim.g.minifiles_active = true
	end,
})
vim.api.nvim_create_autocmd("User", {
	group = minifiles_explorer_group,
	pattern = "MiniFilesExplorerClose",
	callback = function()
		vim.g.minifiles_active = false
	end,
})

-- HACK: Notify LSPs that a file got renamed or moved.
-- Borrowed this from snacks.nvim.
vim.api.nvim_create_autocmd("User", {
	desc = "Notify LSPs that a file was renamed",
	pattern = { "MiniFilesActionRename", "MiniFilesActionMove" },
	callback = function(args)
		local changes = {
			files = {
				{
					oldUri = vim.uri_from_fname(args.data.from),
					newUri = vim.uri_from_fname(args.data.to),
				},
			},
		}
		local will_rename_method, did_rename_method = "workspace/willRenameFiles", "workspace/didRenameFiles"
		local clients = vim.lsp.get_clients()
		for _, client in ipairs(clients) do
			if client:supports_method(will_rename_method) then
				local res = client:request_sync(will_rename_method, changes, 1000, 0)
				if res and res.result then
					vim.lsp.util.apply_workspace_edit(res.result, client.offset_encoding)
				end
			end
		end

		for _, client in ipairs(clients) do
			if client:supports_method(did_rename_method) then
				client:notify(did_rename_method, changes)
			end
		end
	end,
})

vim.api.nvim_create_autocmd("User", {
	desc = "Add minifiles keymaps",
	pattern = "MiniFilesBufferCreate",
	callback = function(args)
		local buf_id = args.data.buf_id

		map_split(buf_id, "<C-w>s", "belowright horizontal")
		map_split(buf_id, "<C-w>v", "belowright vertical")
		vim.keymap.set("n", "<enter>", require("mini.files").go_in, { buffer = buf_id, desc = "Open" })
		vim.keymap.set("n", "gx", ui_open, { buffer = buf_id, desc = "OS open" })
		vim.keymap.set("n", "gy", yank_path, { buffer = buf_id, desc = "Yank path" })
		vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf_id, desc = "Toggle dotfiles" })
	end,
})

local set_mark = function(id, path, desc)
	require("mini.files").set_bookmark(id, path, { desc = desc })
end
vim.api.nvim_create_autocmd("User", {
	pattern = "MiniFilesExplorerOpen",
	callback = function()
		set_mark("c", vim.fn.stdpath("config"), "Config") -- path
		set_mark("w", vim.fn.getcwd, "Working directory") -- callable
		set_mark("~", "~", "Home directory")
	end,
})

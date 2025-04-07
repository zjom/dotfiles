return {
	"aidancz/buvvers.nvim",
	config = function()
		require("buvvers").setup({
			buffer_handle_list_to_buffer_name_list = function(handle_l)
				local name_l

				local default_function = require("buvvers.buffer_handle_list_to_buffer_name_list")
				name_l = default_function(handle_l)

				for n, name in ipairs(name_l) do
					local is_modified = vim.api.nvim_get_option_value("modified", { buf = handle_l[n] })
					local prefix
					if is_modified then
						prefix = "[+]"
					else
						prefix = "[ ]"
					end
					name_l[n] = {
						prefix,
						" ",
						name,
					}
				end

				return name_l
			end,
		})

		local add_buffer_keybindings = function()
			vim.keymap.set("n", "d", function()
				local cursor_buf_handle = require("buvvers").buvvers_buf_get_buf(vim.fn.line("."))
				MiniBufremove.delete(cursor_buf_handle, false)
			end, {
				buffer = require("buvvers").buvvers_get_buf(),
				nowait = true,
			})
			vim.keymap.set("n", "o", function()
				local cursor_buf_handle = require("buvvers").buvvers_buf_get_buf(vim.fn.line("."))
				local previous_win_handle = vim.fn.win_getid(vim.fn.winnr("#"))
				-- https://github.com/nvim-neo-tree/neo-tree.nvim/blob/0b44040ec7b8472dfc504bbcec735419347797ad/lua/neo-tree/utils/init.lua#L643
				vim.api.nvim_win_set_buf(previous_win_handle, cursor_buf_handle)
				vim.api.nvim_set_current_win(previous_win_handle)
			end, {
				buffer = require("buvvers").buvvers_get_buf(),
				nowait = true,
			})
		end

		vim.keymap.set("n", "<leader>bl", require("buvvers").toggle)
		-- bind `<leader>bb` to toggle buvvers
		vim.api.nvim_create_augroup("buvvers_config", { clear = true })
		vim.api.nvim_create_autocmd("User", {
			group = "buvvers_config",
			pattern = "BuvversAutocmdEnabled",
			callback = function()
				vim.api.nvim_create_autocmd({
					"BufModifiedSet",
				}, {
					group = "buvvers",
					callback = require("buvvers").buvvers_open,
				})
			end,
		})
		-- use `BuvversAutocmdEnabled` to add a autocmd that refresh buvvers when `BufModifiedSet` event is triggered
		vim.api.nvim_create_autocmd("User", {
			group = "buvvers_config",
			pattern = "BuvversBufEnabled",
			callback = add_buffer_keybindings,
		})
	end,
}

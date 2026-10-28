-- Copied from
-- https://github.com/lewis6991/dotfiles/blob/0071d6f1a97f8f6080eb592c4838d92f77901e84/config/nvim/lua/gizmos/marksigns.lua

local ns = vim.api.nvim_create_namespace("zjom/marks")

---@param bufnr integer
---@param mark  vim.fn.getmarklist.ret.item
local function decor_mark(bufnr, mark)
	pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, mark.pos[2] - 1, 0, {
		sign_text = mark.mark:sub(2),
		sign_hl_group = "DiagnosticSignOk",
	})
end

---@param mark vim.fn.getmarklist.ret.item
local function is_letter_mark(mark)
	return mark.mark:match("^.[a-zA-Z]$") ~= nil
end

vim.api.nvim_set_decoration_provider(ns, {
	on_win = function(_, _, bufnr, top_row, bot_row)
		local current_file = vim.api.nvim_buf_get_name(bufnr)
		if current_file == "" then
			return
		end

		vim.api.nvim_buf_clear_namespace(bufnr, ns, top_row, bot_row)

		local global_marks = vim.fn.getmarklist()
		for _, mark in ipairs(global_marks) do
			if is_letter_mark(mark) and vim.fn.fnamemodify(mark.file, ":p:a") == current_file then
				decor_mark(bufnr, mark)
			end
		end

		local local_marks = vim.fn.getmarklist(bufnr)
		for _, mark in ipairs(local_marks) do
			if is_letter_mark(mark) then
				decor_mark(bufnr, mark)
			end
		end
	end,
})

-- Redraw the screen when an `m` command changes the marks.
vim.on_key(function(_, typed)
	if typed:sub(1, 1) ~= "m" then
		return
	end

	local mark = typed:sub(2)

	vim.schedule(function()
		if mark:match("[A-Z]") then
			for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
				vim.api.nvim__redraw({ win = win, range = { 0, -1 } })
			end
		else
			vim.api.nvim__redraw({ range = { 0, -1 } })
		end
	end)
end, ns)

--- A lightbulb similar to the lightbulb of VSCode. The implementation is based
--- on
--- https://github.com/nvimdev/lspsaga.nvim/blob/8efe00d6aed9db6449969f889170f1a7e43101a1/lua/lspsaga/codeaction/lightbulb.lua

local M = {}

local lb_name = "zjom/lightbulb"
local lb_namespace = vim.api.nvim_create_namespace(lb_name)
local lb_icon = ""
local lb_group = vim.api.nvim_create_augroup(lb_name, {})
local code_action_method = "textDocument/codeAction" ---@type vim.lsp.protocol.Method.ClientToServer.Request

local timer = vim.uv.new_timer()
assert(timer, "Timer was not initialized")

local updated_bufnr = nil

---@param bufnr number?
---@param line  number?
local function set_lightbulb(bufnr, line)
	if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end

	vim.api.nvim_buf_clear_namespace(bufnr, lb_namespace, 0, -1)

	-- Check again that the mode is not insert mode, because sometimes the
	-- autocommand fails.
	if not line or vim.startswith(vim.api.nvim_get_mode().mode, "i") then
		return
	end

	pcall(vim.api.nvim_buf_set_extmark, bufnr, lb_namespace, line, -1, {
		virt_text = { { " " .. lb_icon, "DiagnosticSignHint" } },
		hl_mode = "combine",
	})

	updated_bufnr = bufnr
end

---@param bufnr  number
---@param client vim.lsp.Client
local function request_code_actions(bufnr, client)
	local winnr = vim.api.nvim_get_current_win()
	if vim.api.nvim_win_get_buf(winnr) ~= bufnr then
		return
	end

	local line = vim.api.nvim_win_get_cursor(0)[1] - 1
	local diagnostics = vim.lsp.diagnostic.from(vim.diagnostic.get(bufnr, { lnum = line }))

	---@type lsp.CodeActionParams
	local params = vim.lsp.util.make_range_params(winnr, client.offset_encoding)
	params.context = { diagnostics = diagnostics, triggerKind = vim.lsp.protocol.CodeActionTriggerKind.Automatic }

	vim.lsp.buf_request(bufnr, code_action_method, params, function(_, res, _)
		if vim.api.nvim_get_current_buf() ~= bufnr then
			return
		end

		set_lightbulb(bufnr, (res and #res > 0 and line) or nil)
	end)
end

---@param bufnr  number
---@param client vim.lsp.Client
local function debounced_render(bufnr, client)
	timer:stop()
	set_lightbulb(updated_bufnr)
	timer:start(100, 0, function()
		timer:stop()
		vim.schedule(function()
			if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_get_current_buf() == bufnr then
				request_code_actions(bufnr, client)
			end
		end)
	end)
end

---@param bufnr  integer
---@param client vim.lsp.Client
M.attach_lightbulb = function(bufnr, client)
	local buf_group_name = lb_name .. tostring(bufnr)
	if pcall(vim.api.nvim_get_autocmds, { group = buf_group_name, buffer = bufnr }) then
		return
	end

	local lb_buf_group = vim.api.nvim_create_augroup(buf_group_name, { clear = true })
	vim.api.nvim_create_autocmd("CursorMoved", {
		group = lb_buf_group,
		desc = "Update lightbulb when moving the cursor in normal/visual mode",
		buffer = bufnr,
		callback = function()
			debounced_render(bufnr, client)
		end,
	})

	vim.api.nvim_create_autocmd({ "InsertEnter", "BufLeave" }, {
		group = lb_buf_group,
		desc = "Update lightbulb when entering insert mode or leaving the buffer",
		buffer = bufnr,
		callback = function()
			set_lightbulb(bufnr, nil)
		end,
	})

	vim.api.nvim_create_autocmd("LspDetach", {
		group = lb_group,
		desc = "Detach code action lightbulb",
		buffer = bufnr,
		callback = function()
			pcall(vim.api.nvim_del_augroup_by_name, lb_name .. tostring(bufnr))
		end,
	})
end

return M

local M = {}

---@param client vim.lsp.Client
M.defer_to_workspace_config = function(client)
	if client.workspace_folders then
		local path = client.workspace_folders[1].name
		if
			path ~= vim.g.config_checkout
			and (vim.uv.fs_stat(path .. "/.emmyrc.json") or vim.uv.fs_stat(path .. "/.luarc.json"))
		then
			client.config.settings = {}
		end
	end
end

return M

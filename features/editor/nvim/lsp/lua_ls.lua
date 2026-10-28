return {
	on_init = function(client)
		-- If the workspace has its own emmylua_ls or lua_ls config file, use
		-- that file.
		if client.workspace_folders then
			local path = client.workspace_folders[1].name
			if
				path ~= vim.g.config_checkout
				and (vim.uv.fs_stat(path .. "/.emmyrc.json") or vim.uv.fs_stat(path .. "/.luarc.json"))
			then
				client.config.settings = {}
			end
		end
	end,
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			workspace = {
				checkThirdParty = false,
				library = vim.api.nvim_get_runtime_file("", true),
				-- If lua_ls is very slow on your computer, use this value instead:
				-- library = { vim.env.VIMRUNTIME }
			},
			completion = {
				callSnippet = "Replace",
			},
			diagnostics = { globals = { "vim" } },
		},
	},
}

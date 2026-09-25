return {
	-- cmd = {...},
	-- filetypes { ...},
	-- capabilities = {},

	on_init = function(client)
		-- If the workspace has its own emmylua_ls/lua_ls config file, defer to it.
		if client.workspace_folders then
			local path = client.workspace_folders[1].name
			if
				path ~= vim.fn.stdpath("config")
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
				-- Tells lua_ls where to find all the Lua files that you have loaded
				-- for your neovim configuration.
				-- library = {
				--   "${3rd}/luv/library",
				--   unpack(vim.api.nvim_get_runtime_file("", true))
				-- }
				-- If lua_ls is really slow on your computer, you can try this instead:
				-- library = { vim.env.VIMRUNTIME }
			},
			completion = {
				callSnippet = "Replace",
			},
			diagnostics = { globals = { "vim" } },
			-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
			-- diagnostics = { disable = { 'missing-fields' } },
		},
	},
}

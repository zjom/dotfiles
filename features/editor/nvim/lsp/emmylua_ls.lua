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
		emmylua = {
			-- Tell the server which Lua version you use (for Neovim, this is
			-- usually LuaJIT).
			runtime = { version = "LuaJIT" },
			diagnostics = { globals = { "vim" } },
			-- Give the server the Neovim runtime files.
			workspace = {
				-- library = {
				--   vim.env.VIMRUNTIME,
				--   -- For LSP Settings Type Annotations: https://github.com/neovim/nvim-lspconfig#lsp-settings-type-annotations
				--   vim.api.nvim_get_runtime_file('lua/lspconfig', false)[1],
				-- },
				-- Alternatively, add all of 'runtimepath'. This alternative can be
				-- slower.
				library = vim.api.nvim_get_runtime_file("", true),
			},
		},
	},
}

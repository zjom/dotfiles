return {
	on_init = require("config.lua_workspace").defer_to_workspace_config,
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

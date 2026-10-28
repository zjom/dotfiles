return {
	on_init = require("config.lua_workspace").defer_to_workspace_config,
	settings = {
		emmylua = {
			runtime = { version = "LuaJIT" },
			diagnostics = { globals = { "vim" } },
			workspace = {
				-- All of 'runtimepath', which is slower than $VIMRUNTIME only.
				library = vim.api.nvim_get_runtime_file("", true),
			},
		},
	},
}

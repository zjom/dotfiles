-- Rust analyzer doesn't really support per project/ workspace config.
-- This is a hacky workaround.
local function get_project_rustanalyzer_settings()
	local handle = io.open(vim.fn.resolve(vim.fn.getcwd() .. "/./.rust-analyzer.json"))
	if not handle then
		return {}
	end
	local out = handle:read("*a")
	handle:close()
	local config = vim.json.decode(out)
	if type(config) == "table" then
		return config
	end
	return {}
end

return {
	settings = {
		["rust-analyzer"] = vim.tbl_deep_extend(
			"force",
			{
				check = {
					command = "clippy",
				},
			},
			get_project_rustanalyzer_settings(),
			{
				-- Overrides (forces these regardless of what's in .rust-analyzer.json
				-- procMacro = { enable = true },
				-- diagnostics = { disabled = { "inactive-code" } },
			}
		),
	},
}

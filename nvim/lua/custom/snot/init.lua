vim.print("hello")
local M = {}

M.schema = { directory = vim.fs.normalize(vim.fs.joinpath(vim.env.XDG_CONFIG_HOME, "../", "notes")) }

---@param cfg table | nil Configuation for simple-notes
function M.setup(cfg)
	cfg = cfg or {}
	vim.print(cfg.schema or M.schema)
end

return M

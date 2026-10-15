-- load colorscheme first
vim.pack.add({ "https://github.com/vague2k/vague.nvim" })
require("vague").setup({
	transparent = true,
})

vim.cmd("colorscheme vague")
vim.cmd(":hi statusline guibg=NONE")

-- Iterate over all Lua files in the plugins directory and load them. The
-- directory is the one this file is in, wherever the configuration was loaded from.
local plugins_dir = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2))
for file_name, type in vim.fs.dir(plugins_dir) do
	if type == "file" and file_name:match("%.lua$") and file_name ~= "init.lua" then
		local module = file_name:gsub("%.lua$", "")
		require("plugins." .. module)
	end
end

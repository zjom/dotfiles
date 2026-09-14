-- load colorscheme first
vim.pack.add({ "https://github.com/vague2k/vague.nvim" })
require("vague").setup({
	transparent = true,
})

vim.cmd("colorscheme vague")
vim.cmd(":hi statusline guibg=NONE")

-- Iterate over all Lua files in the plugins directory and load them
local plugins_dir = vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "plugins")
for file_name, type in vim.fs.dir(plugins_dir) do
	if type == "file" and file_name:match("%.lua$") and file_name ~= "init.lua" then
		local module = file_name:gsub("%.lua$", "")
		require("plugins." .. module)
	end
end

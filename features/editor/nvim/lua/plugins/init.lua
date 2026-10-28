-- Load the colour scheme first.
vim.pack.add({ "https://github.com/vague2k/vague.nvim" })
require("vague").setup({
	transparent = true,
})

vim.cmd("colorscheme vague")
vim.cmd(":hi statusline guibg=NONE")

-- The directory that contains this file, independent of the location of the
-- loaded configuration.
local plugins_dir = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2))
for file_name, type in vim.fs.dir(plugins_dir) do
	if type == "file" and file_name:match("%.lua$") and file_name ~= "init.lua" then
		local module = file_name:gsub("%.lua$", "")
		require("plugins." .. module)
	end
end

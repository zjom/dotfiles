vim.filetype.add({
	filename = {
		[".eslintrc.json"] = "jsonc",
	},
	pattern = {
		["tsconfig*.json"] = "jsonc",
		[".*/%.vscode/.*%.json"] = "jsonc",
		-- Copied from LazyVim. Mark huge files, so that other code can disable
		-- features for these files.
		[".*"] = function(path, bufnr)
			return vim.bo[bufnr]
					and vim.bo[bufnr].filetype ~= "bigfile"
					and path
					and vim.fn.getfsize(path) > (1024 * 500)
					and "bigfile"
				or nil
		end,
	},
})

vim.filetype.add({ extension = { tf = "terraform" } })

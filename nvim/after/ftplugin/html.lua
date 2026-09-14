-- Helper function to find and jump to the appropriate heading
local function jump_heading(forward)
	-- Find the closest heading backwards to determine our current context.
	-- 'b' = backward, 'c' = accept match at cursor, 'W' = no wrap, 'n' = do not move cursor
	local context_lnum = vim.fn.search([[<h[1-6]\(>\|\s\)]], "bcWn")

	-- Default to "6" if no previous heading is found (e.g., top of file)
	local level = "6"
	if context_lnum > 0 then
		local line = vim.fn.getline(context_lnum)
		local match = line:match("<h([1-6])")
		if match then
			level = match
		end
	end

	local pattern = [[<h[1-]] .. level .. [[]\(>\|\s\)]]
	local search_flags = forward and "W" or "bW"
	vim.fn.search(pattern, search_flags)
end

-- Keymaps
vim.keymap.set({ "n", "x" }, "]]", function()
	jump_heading(true)
end, { desc = "Jump to next HTML heading of same/higher level" })

vim.keymap.set({ "n", "x" }, "[[", function()
	jump_heading(false)
end, { desc = "Jump to previous HTML heading of same/higher level" })

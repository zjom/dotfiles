-- Helper function that finds the applicable heading and jumps to that heading.
local function jump_heading(forward)
	-- Find the nearest heading before the cursor, to get the current context.
	-- 'b' = backward, 'c' = accept a match at the cursor, 'W' = no wrap, 'n' =
	-- do not move the cursor.
	local context_lnum = vim.fn.search([[<h[1-6]\(>\|\s\)]], "bcWn")

	-- If there is no heading before the cursor (for example, at the top of the
	-- file), use "6".
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

-- Keymaps.
vim.keymap.set({ "n", "x" }, "]]", function()
	jump_heading(true)
end, { desc = "Jump to next HTML heading of same/higher level" })

vim.keymap.set({ "n", "x" }, "[[", function()
	jump_heading(false)
end, { desc = "Jump to previous HTML heading of same/higher level" })

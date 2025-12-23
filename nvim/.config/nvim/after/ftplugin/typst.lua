vim.opt_local.spell = true

local map = function(mode, keys, func, desc)
	vim.keymap.set(mode, keys, func, { buffer = true, desc = "Go: " .. desc })
end

map("n", "<leader>xp", ":TypstPreviewToggle<enter>", "Toggle Typst [P]review")

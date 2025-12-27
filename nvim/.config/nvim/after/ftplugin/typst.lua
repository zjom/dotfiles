vim.opt_local.spell = true

local map = function(mode, keys, func, desc)
	vim.keymap.set(mode, keys, func, { buffer = true, desc = "Typst: " .. desc })
end

map("n", "<leader>xp", ":TypstPreviewToggle<enter>", "Toggle [P]review")

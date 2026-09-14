require("typst-preview").setup({ open_cmd = 'open -a "Google Chrome" %s' })
vim.opt_local.spell = true
vim.keymap.set("n", "<C-k>", "z=", { desc = "Spell Suggest", buffer = true })
vim.keymap.set("n", "<leader>xp", ":TypstPreviewToggle<enter>", { desc = "[X]oggle TypstPreview" })

vim.keymap.set("n", "<F5>", ":w<CR>:vs | terminal uv run %<CR>", { noremap = true, silent = true })

vim.opt_local.spell = true
vim.opt_local.signcolumn = "no"
vim.g.markdown_fenced_languages = {
  "javascript",
  "typescript",
  "bash",
  "lua",
  "go",
  "rust",
  "c",
  "cpp",
  "python",
  "typst",
}

vim.keymap.set(
  "n",
  "<leader>xp",
  "<cmd>RenderMarkdown buf_toggle<cr>",
  { desc = "[X]oggle markdown Preview", buffer = true }
)

vim.keymap.set("n", "[d", "[s", { buf = 0 })
vim.keymap.set("n", "]d", "]s", { buf = 0 })
vim.keymap.set("n", "]D", "]S", { buf = 0 })
vim.keymap.set("n", "[D", "[S", { buf = 0 })

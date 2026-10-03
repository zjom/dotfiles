vim.pack.add({ "https://github.com/MeanderingProgrammer/render-markdown.nvim" })

require("render-markdown").setup({
  enabled = false,
  anti_conceal = { enabled = true },
  file_types = { "markdown" },
  completions = { lsp = { enabled = true } },
  indent = { enabled = false },
})

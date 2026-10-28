vim.pack.add({
  "https://github.com/L3MON4D3/LuaSnip",
  "https://github.com/rafamadriz/friendly-snippets",
  "https://github.com/saghen/blink.lib",
  "https://github.com/saghen/blink.cmp",
  "https://github.com/tpope/vim-dadbod",
  "https://github.com/kristijanhusak/vim-dadbod-ui",
  "https://github.com/kristijanhusak/vim-dadbod-completion",
})

require("luasnip").setup({})
require("luasnip.loaders.from_vscode").lazy_load()

require("blink.cmp").build():pwait()
require("blink.cmp").setup({
  keymap = {
    preset = "default",
  },
  appearance = {
    nerd_font_variant = "mono",
  },
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 500 },
  },
  sources = {
    default = { "lsp", "path", "snippets" },
    per_filetype = {
      sql = { "dadbod" },
      org = { "orgmode" },
    },
    providers = {
      dadbod = { module = "vim_dadbod_completion.blink" },
    },
  },
  snippets = { preset = "luasnip" },
  fuzzy = { implementation = "prefer_rust_with_warning" },
  signature = { enabled = true },
})

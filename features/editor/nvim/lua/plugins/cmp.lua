local function gh(repo)
  return "https://github.com/" .. repo
end

vim.pack.add({
  gh("L3MON4D3/LuaSnip"),
  gh("rafamadriz/friendly-snippets"),
  gh("saghen/blink.lib"),
  gh("saghen/blink.cmp"),
  gh("tpope/vim-dadbod"),
  gh("kristijanhusak/vim-dadbod-ui"),
  gh("kristijanhusak/vim-dadbod-completion"),
})

require("luasnip").setup({})
require("luasnip.loaders.from_vscode").lazy_load()

require("blink.cmp").build():pwait()
require("blink.cmp").setup({
  keymap = {
    preset = "default",
  },
  appearance = {
    -- 'mono' (default) for 'Nerd Font Mono', or 'normal' for 'Nerd Font'.
    -- Changes the spacing so that the icons align.
    nerd_font_variant = "mono",
  },
  completion = {
    -- By default, press `<c-space>` to show the documentation. To show the
    -- documentation automatically after a delay, set `auto_show = true`.
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

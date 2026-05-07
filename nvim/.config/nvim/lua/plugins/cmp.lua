local function gh(repo)
	return "https://github.com/" .. repo
end

vim.pack.add({
	gh("L3MON4D3/LuaSnip"),
	gh("rafamadriz/friendly-snippets"),
	gh("saghen/blink.cmp"),
})
require("luasnip").setup({})
require("luasnip.loaders.from_vscode").lazy_load()
require("blink.cmp").setup({
	keymap = {
		preset = "default",
	},
	appearance = {
		-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
		-- Adjusts spacing to ensure icons are aligned
		nerd_font_variant = "mono",
	},
	completion = {
		-- By default, you may press `<c-space>` to show the documentation.
		-- Optionally, set `auto_show = true` to show the documentation after a delay.
		documentation = { auto_show = false, auto_show_delay_ms = 500 },
	},
	sources = {
		default = { "lsp", "path", "snippets" },
		per_filetype = {
			sql = { "dadbod" },
			lua = { "LazyDev" },
			-- org = { "orgmode" },
		},
		providers = {
			dadbod = { module = "vim_dadbod_completion.blink" },
			lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
			-- orgmode = {
			-- 	name = "Orgmode",
			-- 	module = "orgmode.org.autocompletion.blink",
			-- 	fallbacks = { "buffer" },
			-- },
		},
	},
	snippets = { preset = "luasnip" },
	fuzzy = { implementation = "prefer_rust_with_warning" },
	signature = { enabled = true },
})

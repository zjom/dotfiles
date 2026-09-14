local function gh(repo)
	return "https://github.com/" .. repo
end

vim.pack.add({
	gh("L3MON4D3/LuaSnip"),
	gh("rafamadriz/friendly-snippets"),
	gh("saghen/blink.cmp"),
	gh("tpope/vim-dadbod"),
	gh("kristijanhusak/vim-dadbod-ui"),
	gh("kristijanhusak/vim-dadbod-completion"),
	gh("nvim-orgmode/orgmode"),
})

require("luasnip").setup({})
require("luasnip.loaders.from_vscode").lazy_load()

require("orgmode").setup({
	org_agenda_files = "~/o/**/*",
	org_default_notes_file = "~/o/refile.org",
})

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
			orgmode = {
				name = "Orgmode",
				module = "orgmode.org.autocompletion.blink",
				fallbacks = { "buffer" },
			},
		},
	},
	snippets = { preset = "luasnip" },
	fuzzy = { implementation = "prefer_rust_with_warning" },
	signature = { enabled = true },
})

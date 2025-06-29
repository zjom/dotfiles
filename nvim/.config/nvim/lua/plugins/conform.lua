return { -- Autoformat
	"stevearc/conform.nvim",
	opts = {
		notify_on_error = false,
		format_on_save = {
			timeout_ms = 500,
			lsp_fallback = true,
		},
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "ruff" },
			go = { "crlfmt", "gofumt" },
			javascript = { "dprint", "prettierd", "prettier", stop_after_first = true },
			json = { "jq" },
			typst = { "typstyle" },
		},
	},
}

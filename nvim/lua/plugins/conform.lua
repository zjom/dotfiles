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
			python = { "isort", "black" },
			go = { "golines", "gofumt", "goimports" },
			javascript = { "deno_fmt", "prettierd", "prettier", stop_after_first = true },
			json = { "jq" },
			markdown = { "deno_fmt" },
		},
	},
}

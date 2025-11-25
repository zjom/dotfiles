return { -- Autoformat
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>f",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = "",
			desc = "[F]ormat buffer",
		},
	},
	opts = {
		notify_on_error = false,
		format_on_save = function(bufnr)
			-- Disable autoformat for files in node_modules
			local bufname = vim.api.nvim_buf_get_name(bufnr)
			if bufname:match("/node_modules/") then
				return
			end

			if -- Disable autoformat for html files in stencil projects
				vim.bo[bufnr].filetype == "html"
				and vim.fs.find("config.stencil.json", { path = bufname, upward = true })[1]
			then
				return
			end

			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end

			---@type conform.FormatOpts
			return { timeout_ms = 500, lsp_format = "fallback" }
		end,
		quiet = true,
		formatters_by_ft = {
			typescript = { "prettier" },
			typescriptreact = { "prettier" },
			javascript = { "prettier" },
			javascriptreact = { "prettier" },
			html = { "prettier" },
			css = { "prettier" },
			scss = { "prettier" },
			lua = { "stylua", lsp_format = "prefer" },
			markdown = { "prettier" },
			yaml = { "prettier" },
			graphql = { "prettier" },
			vue = { "prettier" },
			angular = { "prettier" },
			less = { "prettier" },
			flow = { "prettier" },
			sh = { "beautysh" },
			bash = { "beautysh" },
			zsh = { "beautysh" },
			http = { "kulala-fmt" },
			python = { "black" },
			go = { "gofmt" },
			["_"] = { "trim_whitespace" },
			java = { "google-java-format" },
		},
		formatters = {
			prettier = {
				prepend_args = function()
					return {
						"--no-semi",
						"--single-quote",
						"--no-bracket-spacing",
						"--print-width",
						"80",
						"--config-precedence",
						"prefer-file",
					}
				end,
			},
			beautysh = {
				prepend_args = function()
					return { "--indent-size", "4", "--force-function-style", "fnpar" }
				end,
			},
		},
	},
}

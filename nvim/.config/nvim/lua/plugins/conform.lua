return { -- Autoformat
	"stevearc/conform.nvim",
	init = function()
		-- Use conform for gq.
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

		-- Start auto-formatting by default (and disable with my ToggleFormat command).
		vim.g.autoformat = true
	end,
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	opts = {
		notify_on_error = false,
		format_on_save = function(bufnr)
			-- Disable autoformat for files in node_modules
			local bufname = vim.api.nvim_buf_get_name(bufnr)
			if bufname:match("/node_modules/") then
				return nil
			end

			-- Skip formatting if triggered from my special save command.
			if vim.g.skip_formatting then
				vim.g.skip_formatting = false
				return nil
			end

			-- Stop if we disabled auto-formatting.
			if not vim.g.autoformat then
				return nil
			end

			return {}
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
			lua = { "stylua" },
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
			["_"] = { "trim_whitespace", "trim_newlines" },
			java = { "google-java-format" },
			astro = { "prettier", lsp_format = "prefer" },
			cs = { "csharpier_zjom" },
			csproj = { "csharpier_zjom" },
			json = { "prettier" },
			typst = { "typstyle" },
		},
		formatters = {
			prettier = { require_cwd = true },
			beautysh = {
				prepend_args = function()
					return { "--indent-size", "4", "--force-function-style", "fnpar" }
				end,
			},
			csharpier_zjom = {
				command = "csharpier",
				args = {
					"format",
					"--write-stdout",
				},
				to_stdin = true,
			},
		},
	},
}

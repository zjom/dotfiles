vim.pack.add({ "https://github.com/stevearc/conform.nvim" })
-- Use conform for gq.
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
-- Start auto-formatting by default (and disable with my ToggleFormat command).
vim.g.autoformat = true

require("conform").setup({
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
	quiet = false,
	default_format_opts = {
		lsp_format = "fallback", -- Use external formatters if configured below, otherwise use LSP formatting. Set to `false` to disable LSP formatting entirely.
	},
	formatters_by_ft = {
		["_"] = { "trim_whitespace", "trim_newlines" },
		astro = { "prettier", lsp_format = "prefer" },
		cs = { "csharpier_zjom" },
		csproj = { "csharpier_zjom" },
		css = { "prettier" },
		elixir = { "mix", lsp_format = "prefer" },
		html = { "prettier" },
		http = { "kulala-fmt" },
		java = { "google-java-format" },
		javascript = { "prettier" },
		javascriptreact = { "prettier" },
		json = { "prettier", "jq" },
		less = { "prettier" },
		lua = { "stylua" },
		markdown = { "dprint" },
		ocaml = { "dune fmt" },
		python = {
			-- To fix auto-fixable lint errors.
			"ruff_fix",
			-- To run the Ruff formatter.
			"ruff_format",
			-- To organize the imports.
			"ruff_organize_imports",
		},
		rust = { "rustfmt", lsp_format = "prefer" },
		scss = { "prettier" },
		sql = { "sleek" },
		toml = { "dprint" },
		typescript = { "prettier" },
		typescriptreact = { "prettier" },
		typst = { "typstyle" },
		yaml = { "prettier" },
		zsh = { "beautysh" },
	},
	formatters = {
		prettier = { require_cwd = true },
		csharpier_zjom = {
			command = "csharpier",
			args = {
				"format",
				"--write-stdout",
			},
			to_stdin = true,
		},
	},
})

vim.keymap.set({ "n", "v" }, "<leader>bf", function()
	require("conform").format({ async = true })
end, { desc = "[B]uffer [F]ormat" })

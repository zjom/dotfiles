vim.pack.add({ "https://github.com/stevearc/conform.nvim" })
-- Use conform for gq.
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
-- Start auto-formatting by default (and disable with my ToggleFormat command).
vim.g.autoformat = true

require("conform").setup({
	notify_on_error = false,
	formatters_by_ft = {
		["_"] = { "trim_whitespace", "trim_newlines" },
		astro = { "oxfmt", lsp_format = "prefer" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		cs = { "csharpier_zjom" },
		csproj = { "csharpier_zjom" },
		css = { "oxfmt" },
		elixir = { "mix", lsp_format = "prefer" },
		go = { "gofumpt", lsp_format = "fallback" },
		html = { "oxfmt" },
		http = { "kulala-fmt" },
		java = { "palantir-java-format" },
		javascript = { "oxfmt" },
		javascriptreact = { "oxfmt" },
		just = { "just" },
		jsonc = { "jq" },
		less = { "oxfmt" },
		lua = { "stylua", lsp_format = "prefer" },
		markdown = { "oxfmt" },
		nix = { "nixfmt" },
		nu = { "nufmt" },
		ocaml = { "ocamlformat", lsp_format = "prefer" },
		opentofu = { "tofu_fmt", lsp_format = "fallback" },
		opentofu_vars = { "tofu_fmt", lsp_format = "fallback" },
		terraform = { "tofu_fmt", lsp_format = "fallback" },
		python = {
			-- To fix auto-fixable lint errors.
			"ruff_fix",
			-- To run the Ruff formatter.
			"ruff_format",
			-- To organize the imports.
			"ruff_organize_imports",
		},
		rust = { "rustfmt", lsp_format = "prefer" },
		scss = { "oxfmt" },
		sql = { "sleek" },
		toml = { "oxfmt", lsp_format = "prefer" },
		typescript = { "oxfmt" },
		typescriptreact = { "oxfmt" },
		typst = { "typstyle" },
		yaml = { "oxfmt" },
		zig = { "zigfmt" },
		zsh = { "beautysh" },
	},
	formatters = {
		csharpier_zjom = {
			command = "csharpier",
			args = {
				"format",
				"--write-stdout",
			},
			to_stdin = true,
		},
	},
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
	default_format_opts = {
		lsp_format = "fallback", -- Use external formatters if configured below, otherwise use LSP formatting. Set to `false` to disable LSP formatting entirely.
	},
})

vim.keymap.set({ "n", "v" }, "<leader>bf", function()
	require("conform").format({ async = true })
end, { desc = "[B]uffer [F]ormat" })

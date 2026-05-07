local function gh(repo)
	return "https://github.com/" .. repo
end

vim.pack.add({
	gh("j-hui/fidget.nvim"), -- Useful status updates for LSP.
	gh("neovim/nvim-lspconfig"),
	gh("mason-org/mason.nvim"),
	gh("mason-org/mason-lspconfig.nvim"),
	gh("WhoIsSethDaniel/mason-tool-installer.nvim"),
})
require("fidget").setup({})

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
	callback = function(event)
		local map = function(keys, func, desc, mode)
			mode = mode or "n"
			vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end

		-- Rename the variable under your cursor
		--  Most Language Servers support renaming across files, etc.
		map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
		-- Jump to the definition of the word under your cursor.
		--  This is where a variable was first declared, or where a fn is defined, etc.
		--  To jump back, press <C-T>.
		map("grd", require("telescope.builtin").lsp_definitions, "[G]oto [d]efinition")

		--  This is not Goto Definition, this is Goto Declaration.
		--  For example, in C this would take you to the header
		map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

		-- Find references for the word under your cursor.
		map("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

		-- Jump to the implementation of the word under your cursor.
		--  Useful when your language has ways of declaring types without an actual implementation.
		map("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

		-- Jump to the type of the word under your cursor.
		--  Useful when you're not sure what type a variable is and you want to see
		--  the definition of its *type*, not where it was *defined*.
		map("grt", require("telescope.builtin").lsp_type_definitions, "[G]oto  [T]ype Definition")

		-- Fuzzy find all the symbols in your current document.
		--  Symbols are things like variables, functions, types, etc.
		map("gO", require("telescope.builtin").lsp_document_symbols, "[O]pen Document Symbols")

		-- Fuzzy find all the symbols in your current workspace
		--  Similar to document symbols, except searches over your whole project.
		map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open [W]orkspace Symbols")

		-- Execute a code action, usually your cursor needs to be on top of an error
		-- or a suggestion from your LSP for this to activate.
		map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
		map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

		map("<leader>e", vim.diagnostic.open_float, "[E]xpand Diagnositic")

		-- Opens a popup that displays documentation about the word under your cursor
		--  See `:help K` for why this keymap
		map("K", vim.lsp.buf.hover, "Hover Documentation")

		-- The following two autocommands are used to highlight references of the
		-- word under your cursor when your cursor rests there for a little while.
		--    See `:help CursorHold` for information about when this is executed
		--
		-- When you move your cursor, the highlights will be cleared (the second autocommand).
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
			local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = event.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.document_highlight,
			})

			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = event.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.clear_references,
			})

			vim.api.nvim_create_autocmd("LspDetach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
				callback = function(event2)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
				end,
			})
		end

		if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_codeLens) then
			if client.server_capabilities.codeLensProvider then
				vim.lsp.codelens.enable(true)
			end
		end

		if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
			map("<leader>xh", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
			end, "Toggle Inlay [H]ints")
		end
	end,
})

local servers = {
	roslyn = {},
	ruff = {},
	tinymist = {
		cmd = { "tinymist" },
		filetypes = { "typst" },
		settings = {
			formatterMode = "typstyle",
		},
	},
	ts_ls = {},
	clangd = {
		cmd = {
			"clangd",
			"--background-index",
			"--compile-commands-dir=.",
		},
	},
	elixirls = {
		settings = {
			dialyzerEnabled = true,
			fetchDeps = false,
			enableTestLenses = false,
			suggestSpecs = false,
		},
	},
	jdtls = {},
	marksman = {},
	gopls = {},
	tailwindcss = {},
	eslint = {},
	html = {},
	emmet_ls = {},
	-- ocamllsp = {
	-- 	manual_install = true,
	-- 	settings = {
	-- 		codelens = { enable = true },
	-- 		inlayHints = { enable = true },
	-- 	},
	-- 	filetypes = {
	-- 		"ocaml",
	-- 		"ocaml.interface",
	-- 		"ocaml.menhir",
	-- 		"ocaml.cram",
	-- 	},
	-- },
	lua_ls = {
		-- cmd = {...},
		-- filetypes { ...},
		-- capabilities = {},
		settings = {
			Lua = {
				runtime = { version = "LuaJIT" },
				workspace = {
					checkThirdParty = false,
					-- Tells lua_ls where to find all the Lua files that you have loaded
					-- for your neovim configuration.
					library = {
						"${3rd}/luv/library",
						unpack(vim.api.nvim_get_runtime_file("", true)),
					},
					-- If lua_ls is really slow on your computer, you can try this instead:
					-- library = { vim.env.VIMRUNTIME },
				},
				completion = {
					callSnippet = "Replace",
				},
				-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
				-- diagnostics = { disable = { 'missing-fields' } },
			},
		},
	},
	-- ty = {},
	basedpyright = {},
	rust_analyzer = {
		settings = {
			["rust-analyzer"] = {
				check = {
					command = "clippy",
				},
			},
		},
	},
}

-- Automatically install LSPs and related tools to stdpath for Neovim
require("mason").setup({})

local servers_to_install = vim.tbl_filter(function(key)
	local t = servers[key]
	if type(t) == "table" then
		return not t.manual_install
	else
		return t
	end
end, vim.tbl_keys(servers))

local ensure_installed = servers_to_install
vim.list_extend(ensure_installed, {
	"eslint", -- JavaScript and TypeScript linting
	"prettier", -- Web formatting
	"typstyle", --Typst formatting
	"sleek", -- SQL formatting
	"csharpier", -- C# formatting,
	"xmlformatter", -- Xml formatting
	"dprint", -- General purpose formatting
})

require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

for name, server in pairs(servers) do
	vim.lsp.config(name, server)
	vim.lsp.enable(name)
end

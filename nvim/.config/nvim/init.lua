do
	vim.loader.enable()

	require("config.options")
	require("config.keymaps")
	require("config.autocmds")
	require("config.commands")
	require("config.marks")
	require("config.filetype")
	require("config.lightbulb")
	require("plugins")
end

-- [[ Intro to `vim.pack` ]]
-- `vim.pack` is a new plugin manager built into Neovim,
--  which provides a Lua interface for installing and managing plugins.
--
--  See `:help vim.pack`, `:help vim.pack-examples` or the
--  excellent blog post from the creator of vim.pack and mini.nvim:
--  https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack
--
--  To inspect plugin state and pending updates, run
--    :lua vim.pack.update(nil, { offline = true })
--
--  To update plugins, run
--    :lua vim.pack.update()
--
--
--  Throughout the rest of the config there will be examples
--  of how to install and configure plugins using `vim.pack`.
--
--  In this section we set up some autocommands to run build
--  steps for certain plugins after they are installed or updated.
do
	local function run_build(name, cmd, cwd)
		local result = vim.system(cmd, { cwd = cwd }):wait()
		if result.code ~= 0 then
			local stderr = result.stderr or ""
			local stdout = result.stdout or ""
			local output = stderr ~= "" and stderr or stdout
			if output == "" then
				output = "No output from build command."
			end
			vim.notify(("Build failed for %s:\n%s"):format(name, output), vim.log.levels.ERROR)
		end
	end

	-- This autocommand runs after a plugin is installed or updated and
	--  runs the appropriate build command for that plugin if necessary.
	--
	-- See `:help vim.pack-events`
	vim.api.nvim_create_autocmd("PackChanged", {
		callback = function(ev)
			local name = ev.data.spec.name
			local kind = ev.data.kind
			if kind ~= "install" and kind ~= "update" then
				return
			end

			if name == "telescope-fzf-native.nvim" and vim.fn.executable("make") == 1 then
				run_build(name, { "make" }, ev.data.path)
				return
			end

			if name == "LuaSnip" then
				if vim.fn.has("win32") ~= 1 and vim.fn.executable("make") == 1 then
					run_build(name, { "make", "install_jsregexp" }, ev.data.path)
				end
				return
			end

			if name == "nvim-treesitter" then
				if not ev.data.active then
					vim.cmd.packadd("nvim-treesitter")
				end
				vim.cmd("TSUpdate")
				return
			end
		end,
	})
end

---Because most plugins are hosted on GitHub, you can use the helper
---function to have less repetition in the following sections.
---@param repo string
---@return string
local function gh(repo)
	return "https://github.com/" .. repo
end

do -- quality of life
	vim.pack.add({ gh("nvim-tree/nvim-web-devicons") })

	vim.pack.add({ gh("lewis6991/gitsigns.nvim") })
	require("gitsigns").setup({
		signs = {
			add = { text = "+" },
			change = { text = "~" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
		},
	})

	vim.pack.add({ gh("windwp/nvim-autopairs") })
	require("nvim-autopairs").setup({})
	vim.pack.add({ gh("windwp/nvim-ts-autotag") })
	require("nvim-ts-autotag").setup({})

	-- "gc" to comment visual regions/lines
	vim.pack.add({ gh("numToStr/Comment.nvim") })
	require("Comment").setup()

	-- tmux
	vim.pack.add({ gh("christoomey/vim-tmux-navigator") })

	vim.pack.add({ gh("folke/which-key.nvim") })
	require("which-key").setup({
		-- Document existing key chains
		spec = {
			{ "<leader>b", group = "[B]uffer" },
			{ "<leader>c", group = "[C]ode" },
			{ "<leader>d", group = "[D]ap" },
			{ "<leader>o", group = "[O]rg" },
			{ "<leader>r", group = "[R]equest" },
			{ "<leader><C-R>", group = "[R]estart" },
			{ "<leader>s", group = "[S]earch" },
			{ "<leader>w", group = "[W]orkspace" },
			{ "<leader>x", group = "[X]oggle" },
			{ "<leader>t", group = "[T]ab" },
			{ "<leader>o", group = "[O]rg" },
		},
	})

	-- colorschemes
	vim.pack.add({ gh("vague2k/vague.nvim") })
	require("vague").setup({
		transparent = true,
	})

	vim.cmd("colorscheme vague")
	vim.cmd(":hi statusline guibg=NONE")

	vim.api.nvim_set_hl(0, "@org.agenda.scheduled", { fg = "grey" })
	vim.api.nvim_set_hl(0, "@org.agenda.deadline", { fg = "#FFAAAA" })

	-- Highlight todo, notes, etc in comments
	vim.pack.add({ gh("folke/todo-comments.nvim") })
	require("todo-comments").setup({ signs = true })

	-- [[ mini.nvim ]]
	--  A collection of various small independent plugins/modules
	vim.pack.add({ gh("nvim-mini/mini.nvim") })

	-- Better Around/Inside textobjects
	--
	-- Examples:
	--  - va)  - [V]isually select [A]round [)]parenthen
	--  - yinq - [Y]ank [I]nside [N]ext [']quote
	--  - ci'  - [C]hange [I]nside [']quote
	require("mini.ai").setup({
		mappings = {
			around_next = "aa",
			inside_next = "ii",
		},
		n_lines = 500,
	})

	-- Add/delete/replace surroundings (brackets, quotes, etc.)
	--
	-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
	-- - sd'   - [S]urround [D]elete [']quotes
	-- - sr)'  - [S]urround [R]eplace [)] [']
	require("mini.surround").setup({
		-- Module mappings. Use `''` (empty string) to disable one.
		mappings = {
			add = "gsa", -- Add surrounding in Normal and Visual modes
			delete = "gsd", -- Delete surrounding
			find = "gsf", -- Find surrounding (to the right)
			find_left = "gsF", -- Find surrounding (to the left)
			highlight = "gsh", -- Highlight surrounding
			replace = "gsr", -- Replace surrounding
			update_n_lines = "gsn", -- Update `n_lines`

			suffix_last = "gl", -- Suffix to search with "prev" method
			suffix_next = "gn", -- Suffix to search with "next" method
		},
	})

	-- Save the window layout when closing a buffer.
	vim.keymap.set("n", "<leader>bd", function()
		require("mini.bufremove").delete(0, false)
	end)
end

do -- File explorer
	local function map_split(buf_id, lhs, direction)
		local minifiles = require("mini.files")

		local function rhs()
			local window = minifiles.get_explorer_state().target_window

			-- Noop if the explorer isn't open or the cursor is on a directory.
			if window == nil or minifiles.get_fs_entry().fs_type == "directory" then
				return
			end

			-- Make a new window and set it as target.
			local new_target_window
			vim.api.nvim_win_call(window, function()
				vim.cmd(direction .. " split")
				new_target_window = vim.api.nvim_get_current_win()
			end)

			minifiles.set_target_window(new_target_window)

			-- Go in and close the explorer.
			minifiles.go_in({ close_on_file = true })
		end

		vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = "Split " .. string.sub(direction, 12) })
	end

	-- Yank in register full path of entry under cursor
	local yank_path = function()
		local path = (require("mini.files").get_fs_entry() or {}).path
		if path == nil then
			return vim.notify("Cursor is not on valid entry")
		end
		vim.fn.setreg(vim.v.register, path)
	end

	-- Open path with system default handler (useful for non-text files)
	local ui_open = function()
		vim.ui.open(require("mini.files").get_fs_entry().path)
	end

	local show_dotfiles = true

	local filter_show = function(_)
		return true
	end

	local filter_hide = function(fs_entry)
		return not vim.startswith(fs_entry.name, ".")
	end

	local toggle_dotfiles = function()
		show_dotfiles = not show_dotfiles
		local new_filter = show_dotfiles and filter_show or filter_hide
		require("mini.files").refresh({ content = { filter = new_filter } })
	end

	local minifiles_toggle = function()
		local minifiles = require("mini.files")
		if not minifiles.close() then
			minifiles.open(vim.api.nvim_buf_get_name(0), true)
		end
	end
	require("mini.files").setup({
		content = {
			filter = filter_hide,
			sort = function(entries)
				local function compare_alphanumerically(e1, e2)
					-- Put directories first.
					if e1.is_dir and not e2.is_dir then
						return true
					end
					if not e1.is_dir and e2.is_dir then
						return false
					end
					-- Order numerically based on digits if the text before them is equal.
					if e1.pre_digits == e2.pre_digits and e1.digits ~= nil and e2.digits ~= nil then
						return e1.digits < e2.digits
					end
					-- Otherwise order alphabetically ignoring case.
					return e1.lower_name < e2.lower_name
				end

				local sorted = vim.tbl_map(function(entry)
					local pre_digits, digits = entry.name:match("^(%D*)(%d+)")
					if digits ~= nil then
						digits = tonumber(digits)
					end

					return {
						fs_type = entry.fs_type,
						name = entry.name,
						path = entry.path,
						lower_name = entry.name:lower(),
						is_dir = entry.fs_type == "directory",
						pre_digits = pre_digits,
						digits = digits,
					}
				end, entries)
				table.sort(sorted, compare_alphanumerically)
				-- Keep only the necessary fields.
				return vim.tbl_map(function(x)
					return { name = x.name, fs_type = x.fs_type, path = x.path }
				end, sorted)
			end,
		},
		windows = { width_nofocus = 25 },
		-- Move stuff to the minifiles trash instead of it being gone forever.
		options = { permanent_delete = false },
	})

	vim.keymap.set("n", "<C-e>", minifiles_toggle, { desc = "Toggle File [E]xplorer" })
	vim.keymap.set("n", "<leader>xe", minifiles_toggle, { desc = "Toggle File [E]xplorer" })

	-- Keep track of when the explorer is open to disable format on save.
	local minifiles_explorer_group = vim.api.nvim_create_augroup("zjom/minifiles_explorer", { clear = true })
	vim.api.nvim_create_autocmd("User", {
		group = minifiles_explorer_group,
		pattern = "MiniFilesExplorerOpen",
		callback = function()
			vim.g.minifiles_active = true
		end,
	})
	vim.api.nvim_create_autocmd("User", {
		group = minifiles_explorer_group,
		pattern = "MiniFilesExplorerClose",
		callback = function()
			vim.g.minifiles_active = false
		end,
	})

	-- HACK: Notify LSPs that a file got renamed or moved.
	-- Borrowed this from snacks.nvim.
	vim.api.nvim_create_autocmd("User", {
		desc = "Notify LSPs that a file was renamed",
		pattern = { "MiniFilesActionRename", "MiniFilesActionMove" },
		callback = function(args)
			local changes = {
				files = {
					{
						oldUri = vim.uri_from_fname(args.data.from),
						newUri = vim.uri_from_fname(args.data.to),
					},
				},
			}
			local will_rename_method, did_rename_method = "workspace/willRenameFiles", "workspace/didRenameFiles"
			local clients = vim.lsp.get_clients()
			for _, client in ipairs(clients) do
				if client:supports_method(will_rename_method) then
					local res = client:request_sync(will_rename_method, changes, 1000, 0)
					if res and res.result then
						vim.lsp.util.apply_workspace_edit(res.result, client.offset_encoding)
					end
				end
			end

			for _, client in ipairs(clients) do
				if client:supports_method(did_rename_method) then
					client:notify(did_rename_method, changes)
				end
			end
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		desc = "Add minifiles keymaps",
		pattern = "MiniFilesBufferCreate",
		callback = function(args)
			local buf_id = args.data.buf_id

			map_split(buf_id, "<C-w>s", "belowright horizontal")
			map_split(buf_id, "<C-w>v", "belowright vertical")
			vim.keymap.set("n", "<enter>", require("mini.files").go_in, { buffer = buf_id, desc = "Open" })
			vim.keymap.set("n", "gx", ui_open, { buffer = buf_id, desc = "OS open" })
			vim.keymap.set("n", "gy", yank_path, { buffer = buf_id, desc = "Yank path" })
			vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf_id, desc = "Toggle dotfiles" })
		end,
	})

	local set_mark = function(id, path, desc)
		require("mini.files").set_bookmark(id, path, { desc = desc })
	end
	vim.api.nvim_create_autocmd("User", {
		pattern = "MiniFilesExplorerOpen",
		callback = function()
			set_mark("c", vim.fn.stdpath("config"), "Config") -- path
			set_mark("w", vim.fn.getcwd, "Working directory") -- callable
			set_mark("~", "~", "Home directory")
		end,
	})
end

do -- picker/ fzf
	local telescope_plugins = {
		gh("nvim-lua/plenary.nvim"),
		gh("nvim-telescope/telescope.nvim"),
		gh("nvim-telescope/telescope-ui-select.nvim"),
	}
	if vim.fn.executable("make") == 1 then
		table.insert(telescope_plugins, gh("nvim-telescope/telescope-fzf-native.nvim"))
	end

	vim.pack.add(telescope_plugins)
	-- See `:help telescope` and `:help telescope.setup()`
	require("telescope").setup({
		-- You can put your default mappings / updates / etc. in here
		--  All the info you're looking for is in `:help telescope.setup()`
		defaults = {
			--   mappings = {
			--     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
			--   },
			file_ignore_patterns = {
				"node_modules",
				"vendor",
				"venv",
				".venv",
			},
		},
		extensions = {
			["ui-select"] = { require("telescope.themes").get_dropdown() },
		},
	})

	pcall(require("telescope").load_extension, "fzf")
	pcall(require("telescope").load_extension, "ui-select")

	local builtin = require("telescope.builtin")
	vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
	vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
	vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
	vim.keymap.set("n", "ff", builtin.find_files, { desc = "[F]ind [F]iles" })
	vim.keymap.set({ "n", "v" }, "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
	vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
	vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
	vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
	vim.keymap.set("n", "<leader>ss", builtin.lsp_document_symbols, { desc = "[S]earch document [S]ymbols" })
	vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
	vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
	vim.keymap.set("n", "<leader>/", function()
		builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
			winblend = 10,
			previewer = false,
		}))
	end, { desc = "[/] Fuzzily search in current buffer" })
	vim.keymap.set("n", "<leader>s/", function()
		builtin.live_grep({
			grep_open_files = true,
			prompt_title = "Live Grep in Open Files",
		})
	end, { desc = "[S]earch [/] in Open Files" })
	vim.keymap.set("n", "<leader>sc", function()
		builtin.find_files({ cwd = "~/dotfiles/" })
	end, { desc = "[S]earch [C]onfig" })
	vim.keymap.set("i", "<C-x><C-i>", builtin.symbols, { desc = "[x] [I]nsert Symbols" })
end

do --lsp
	-- Useful status updates for LSP.
	vim.pack.add({ gh("j-hui/fidget.nvim") })
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
			if
				client
				and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
			then
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

	vim.pack.add({
		gh("neovim/nvim-lspconfig"),
		gh("mason-org/mason.nvim"),
		gh("mason-org/mason-lspconfig.nvim"),
		gh("WhoIsSethDaniel/mason-tool-installer.nvim"),
	})
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

	-- trouble diagnostics
	vim.pack.add({ gh("folke/trouble.nvim") })
	require("trouble").setup()
	vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", {
		desc = "Diagnostics (Trouble)",
	})
end

do -- formatting
	vim.pack.add({ gh("stevearc/conform.nvim") })
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
			markdown = { "prettier" },
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
end

do -- AUTOCOMPLETE & SNIPPETS
	vim.pack.add({ { src = gh("L3MON4D3/LuaSnip"), version = vim.version.range("2.*") } })
	require("luasnip").setup({})

	vim.pack.add({ gh("rafamadriz/friendly-snippets") })
	require("luasnip.loaders.from_vscode").lazy_load()

	vim.pack.add({ { src = gh("saghen/blink.cmp"), version = vim.version.range("1.*") } })
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
				-- org = { "orgmode" },
			},
			providers = {
				dadbod = { module = "vim_dadbod_completion.blink" },
				lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
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
end

do -- TREESITTER
	vim.pack.add({ { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" } })
	local parsers = {
		"bash",
		"c",
		"diff",
		"gitcommit",
		"go",
		"html",
		"java",
		"javascript",
		"json",
		"json5",
		"lua",
		"markdown",
		"markdown_inline",
		"python",
		"query",
		"regex",
		"rust",
		"scss",
		"toml",
		"tsx",
		"typescript",
		"vim",
		"vimdoc",
		"yaml",
	}
	require("nvim-treesitter").install(parsers)

	---@param buf integer
	---@param language string
	local function treesitter_try_attach(buf, language)
		-- Check if a parser exists and load it
		if not vim.treesitter.language.add(language) then
			return
		end
		-- Enable syntax highlighting and other treesitter features
		vim.treesitter.start(buf, language)

		-- Enable treesitter based folds
		-- For more info on folds see `:help folds`
		vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		vim.wo.foldmethod = "expr"

		-- Check if treesitter indentation is available for this language, and if so enable it
		-- in case there is no indent query, the indentexpr will fallback to the vim's built in one
		local has_indent_query = vim.treesitter.query.get(language, "indents") ~= nil

		-- Enable treesitter based indentation
		if has_indent_query then
			vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end

	local available_parsers = require("nvim-treesitter").get_available()
	vim.api.nvim_create_autocmd("FileType", {
		callback = function(args)
			local buf, filetype = args.buf, args.match

			local language = vim.treesitter.language.get_lang(filetype)
			if not language then
				return
			end

			local installed_parsers = require("nvim-treesitter").get_installed("parsers")

			if vim.tbl_contains(installed_parsers, language) then
				-- Enable the parser if it is already installed
				treesitter_try_attach(buf, language)
			elseif vim.tbl_contains(available_parsers, language) then
				-- If a parser is available in `nvim-treesitter`, auto-install it and enable it after the installation is done
				require("nvim-treesitter").install(language):await(function()
					treesitter_try_attach(buf, language)
				end)
			else
				-- Try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
				treesitter_try_attach(buf, language)
			end
		end,
	})
end

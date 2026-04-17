-- Highlight, edit, and navigate code.
local ensureInstalled = {
	"bash",
	"c",
	"cpp",
	"fish",
	"gitcommit",
	"go",
	"graphql",
	"html",
	"hyprlang",
	"java",
	"javascript",
	"json",
	"json5",
	"lua",
	"markdown",
	"markdown_inline",
	"python",
	"query",
	"rasi",
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

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		dependencies = {
			{
				"nvim-treesitter/nvim-treesitter-context",
				opts = {
					-- Avoid the sticky context from growing a lot.
					max_lines = 3,
					-- Match the context lines to the source code.
					multiline_threshold = 1,
					-- Disable it when the window is too small.
					min_window_height = 20,
				},
				keys = {
					{
						"[c",
						function()
							-- Jump to previous change when in diffview.
							if vim.wo.diff then
								return "[c"
							else
								vim.schedule(function()
									require("treesitter-context").go_to_context()
								end)
								return "<Ignore>"
							end
						end,
						desc = "Jump to upper context",
						expr = true,
					},
				},
			},
		},
		version = false,
		build = ":TSUpdate",
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				callback = function()
					-- Enable treesitter highlighting and disable regex syntax
					pcall(vim.treesitter.start)
					-- Enable treesitter-based indentation
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					-- Enable treesitter-based folding
					vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
					vim.wo[0][0].foldmethod = "expr"
				end,
			})
			local alreadyInstalled = require("nvim-treesitter.config").get_installed()
			local parsersToInstall = vim.iter(ensureInstalled)
				:filter(function(parser)
					return not vim.tbl_contains(alreadyInstalled, parser)
				end)
				:totable()
			require("nvim-treesitter").install(parsersToInstall)
		end,

		opts = {
			highlight = { enable = true },
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<cr>",
					node_incremental = "<cr>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
			indent = {
				enable = true,
				-- Treesitter unindents Yaml lists for some reason.
				disable = { "yaml" },
			},
		},
		config = function(_, opts)
			local toggle_inc_selection_group =
				vim.api.nvim_create_augroup("zjom/toggle_inc_selection", { clear = true })
			vim.api.nvim_create_autocmd("CmdwinEnter", {
				desc = "Disable incremental selection when entering the cmdline window",
				group = toggle_inc_selection_group,
				command = "TSBufDisable incremental_selection",
			})
			vim.api.nvim_create_autocmd("CmdwinLeave", {
				desc = "Enable incremental selection when leaving the cmdline window",
				group = toggle_inc_selection_group,
				command = "TSBufEnable incremental_selection",
			})

			require("nvim-treesitter").setup(opts)
		end,
	},
}

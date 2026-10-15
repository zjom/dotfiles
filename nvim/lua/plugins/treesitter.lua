vim.pack.add({ { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" } })

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
	"latex",
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
	"typst",
	"vim",
	"vimdoc",
	"yaml",
}
require("nvim-treesitter").install(parsers)
---@param buf      integer
---@param language string
local function treesitter_try_attach(buf, language)
	-- If a parser exists, load the parser.
	if not vim.treesitter.language.add(language) then
		return
	end
	-- Enable syntax highlighting and the other treesitter features.
	vim.treesitter.start(buf, language)

	-- Enable folds that use treesitter. For more information about folds, see
	-- `:help folds`.
	vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
	vim.wo.foldmethod = "expr"

	-- If treesitter indentation is available for this language, enable
	-- treesitter indentation. If there is no indent query, indentexpr uses the
	-- built-in indentation of Vim.
	local has_indent_query = vim.treesitter.query.get(language, "indents") ~= nil

	-- Enable indentation that uses treesitter.
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
			-- If the parser is already installed, enable the parser.
			treesitter_try_attach(buf, language)
		elseif vim.tbl_contains(available_parsers, language) then
			-- If `nvim-treesitter` has a parser for the language, install the
			-- parser automatically. Enable the parser after the installation.
			require("nvim-treesitter").install(language):await(function()
				treesitter_try_attach(buf, language)
			end)
		else
			-- The parser can exist without `nvim-treesitter`. Thus, try to
			-- enable the treesitter features.
			treesitter_try_attach(buf, language)
		end
	end,
})

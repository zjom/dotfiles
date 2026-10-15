-- Set <space> as the leader key. See `:help mapleader`.
-- NOTE: Set the leader key before the plugins load. Otherwise, the plugins use
-- the wrong leader key.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- The checkout that contains the editable source of this configuration. Neovim
-- runs the copy in the Nix store (modules/nodes/nvim.nix), so stdpath("config")
-- does not point to the checkout.
vim.g.config_checkout = vim.fs.normalize("~/dotfiles/nvim")

-- [[ Options ]]
-- See `:help vim.opt`. For a list of all options, see `:help option-list`.

-- Indent with 2 spaces.
vim.o.sw = 2
vim.o.ts = 2
vim.o.et = true

-- Show whitespace. See `:help 'list'` and `:help 'listchars'`.
vim.o.list = true
vim.opt.listchars = { space = "⋅", trail = "⋅", tab = "  ↦" }

-- Show line numbers by default.
vim.wo.number = true
vim.wo.relativenumber = true

-- Enable the mouse.
vim.o.mouse = "a"

-- Disable horizontal scrolling.
vim.o.mousescroll = "ver:3,hor:0"

-- Do not show the mode, because the status line already shows it.
vim.o.showmode = false

-- Wrap long lines at word boundaries.
vim.o.linebreak = true

-- Folding.
vim.o.foldcolumn = "1"
vim.o.foldlevelstart = 99
vim.wo.foldtext = ""

-- Synchronize the clipboard of the OS with Neovim. To keep the clipboard of the
-- OS separate, remove this option. See `:help 'clipboard'`.
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

-- Save the undo history.
vim.o.undofile = true

-- Highlight the search matches.
vim.o.hlsearch = true

-- Search without case sensitivity, unless the search contains \C or a capital
-- letter.
vim.o.ignorecase = true
vim.o.smartcase = true

-- Always show the sign column.
vim.wo.signcolumn = "yes"

-- Decrease the update time.
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Diff mode settings. A very large context value disables folding.
vim.opt.diffopt:append("vertical,context:99")
vim.opt.shortmess:append({
	w = true,
	s = true,
})
-- Configure where new splits open.
vim.o.splitright = true
vim.o.splitbelow = true

-- Show a live preview of substitutions while you type.
vim.o.inccommand = "split"

-- Highlight the line that contains the cursor.
vim.o.cursorline = true

-- The minimum number of screen lines above and below the cursor.
vim.o.scrolloff = 10

-- Allow concealed text (for example, * for bold).
vim.o.conceallevel = 2

-- Disable the swap file.
vim.o.swapfile = false

-- Disable cursor blinking in terminal mode.
vim.o.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,t:block-TermCursor"

-- Disable the health checks for these providers.
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

vim.o.statusline =
	"%<%f %h%w%m%r %y %{% v:lua.require('vim._core.util').term_exitcode() %}%=%{% luaeval('(package.loaded[''vim.ui''] and vim.api.nvim_get_current_win() == tonumber(vim.g.actual_curwin or -1) and vim.ui.progress_status()) or '''' ')%}%{% &showcmdloc == 'statusline' ? '%-10.S ' : '' %}%{% exists('b:keymap_name') ? '<'..b:keymap_name..'> ' : '' %}%{% &busy > 0 ? '◐ ' : '' %}%{% luaeval('(package.loaded[''vim.diagnostic''] and next(vim.diagnostic.count()) and vim.diagnostic.status() .. '' '') or '''' ') %}%{% &ruler ? ( &rulerformat == '' ? '%-14.(%l,%c%V%) %P' : &rulerformat ) : '' %}"

-- Diagnostics.

vim.diagnostic.config({
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = { severity = vim.diagnostic.severity.ERROR },
	signs = vim.g.have_nerd_font and {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚 ",
			[vim.diagnostic.severity.WARN] = "󰀪 ",
			[vim.diagnostic.severity.INFO] = "󰋽 ",
			[vim.diagnostic.severity.HINT] = "󰌶 ",
		},
	} or {},
	virtual_text = {
		source = "if_many",
		spacing = 2,
		format = function(diagnostic)
			local diagnostic_message = {
				[vim.diagnostic.severity.ERROR] = diagnostic.message,
				[vim.diagnostic.severity.WARN] = diagnostic.message,
				[vim.diagnostic.severity.INFO] = diagnostic.message,
				[vim.diagnostic.severity.HINT] = diagnostic.message,
			}
			return diagnostic_message[diagnostic.severity]
		end,
	},
})

-- NOTE: Set the leader key before the plugins load. Otherwise, the plugins use
-- the wrong leader key.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- The checkout that contains the editable source of this configuration. Neovim
-- runs the copy in the Nix store (features/editor/nvim.nix). On a host, Home
-- Manager links stdpath("config") to the checkout (features/editor/default.nix).
-- Under `nix run`, there is no link, and vim.g.dotfiles is nil.
vim.g.config_checkout = vim.fn.resolve(vim.fn.stdpath("config"))
vim.g.dotfiles = vim.fs.root(vim.g.config_checkout, "flake.nix")

-- Indent with 2 spaces.
vim.o.sw = 2
vim.o.ts = 2
vim.o.et = true

vim.o.list = true
vim.opt.listchars = { space = "⋅", trail = "⋅", tab = "  ↦" }

vim.wo.number = true
vim.wo.relativenumber = true

vim.o.mouse = "a"

-- Disable horizontal scrolling.
vim.o.mousescroll = "ver:3,hor:0"

-- Do not show the mode, because the status line already shows it.
vim.o.showmode = false

-- Wrap long lines at word boundaries.
vim.o.linebreak = true

vim.o.foldcolumn = "1"
vim.o.foldlevelstart = 99
vim.wo.foldtext = ""

-- Synchronize the clipboard of the OS with Neovim. To keep the clipboard of the
-- OS separate, remove this option. See `:help 'clipboard'`.
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

vim.o.undofile = true

vim.o.hlsearch = true

vim.o.ignorecase = true
vim.o.smartcase = true

vim.wo.signcolumn = "yes"

vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Diff mode settings. A very large context value disables folding.
vim.opt.diffopt:append("vertical,context:99")
vim.opt.shortmess:append({
	w = true,
	s = true,
})
vim.o.splitright = true
vim.o.splitbelow = true

vim.o.inccommand = "split"

vim.o.cursorline = true

vim.o.scrolloff = 10

vim.o.conceallevel = 2

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

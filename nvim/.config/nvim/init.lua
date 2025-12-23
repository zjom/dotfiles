-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end

require("config.options")
require("config.keymaps")
require("config.autocmds")

local plugins = 'plugins'

vim.opt.rtp:prepend(lazypath)

require('lazy').setup(plugins, {
	-- Don't bother me when tweaking plugins.
	change_detection = { notify = false },
	-- None of my plugins use luarocks so disable this.
	rocks = {
		enabled = false,
	},
	performance = {
		rtp = {
			-- Stuff I don't use.
			disabled_plugins = {
				'gzip',
				'netrwPlugin',
				'rplugin',
				'tarPlugin',
				'tohtml',
				'tutor',
				'zipPlugin',
			},
		},
	},
})

return {
	"epwalsh/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	lazy = true,
	cmd = "ObsidianSearch",
	ft = "markdown",
	-- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
	-- event = {
	--   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
	--   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
	--   "BufReadPre path/to/my-vault/**.md",
	--   "BufNewFile path/to/my-vault/**.md",
	-- },
	dependencies = {
		-- Required.
		"nvim-lua/plenary.nvim",
	},
	opts = {
		workspaces = {
			{
				name = "default",
				path = "/Users/zihanjin/Library/Mobile Documents/iCloud~md~obsidian/Documents/Default/",
			},
		},

		templates = {
			folder = "/Users/zihanjin/Library/Mobile Documents/iCloud~md~obsidian/Documents/templates/",
			date_format = "%Y-%m-%d-%a",
			time_format = "%H:%M",
		},

		-- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
		-- URL it will be ignored but you can customize this behavior here.
		---@param url string
		follow_url_func = function(url)
			local ends_with_image_extension = function(filename)
				return string.match(filename, "%.([^%.]+)$")
					and string.match(filename, "%.([^%.]+)$"):lower()
					and (
						string.match(filename, "%.([^%.]+)$"):lower() == "jpg"
						or string.match(filename, "%.([^%.]+)$"):lower() == "jpeg"
						or string.match(filename, "%.([^%.]+)$"):lower() == "png"
						or string.match(filename, "%.([^%.]+)$"):lower() == "gif"
						or string.match(filename, "%.([^%.]+)$"):lower() == "bmp"
						or string.match(filename, "%.([^%.]+)$"):lower() == "tiff"
					)
			end

			-- Remove file:// from the url
			url = url.gsub(url, "^file:///", "")

			--check if is image
			if ends_with_image_extension(url) then
				vim.fn.jobstart({ "qlmanage", "-p", url })
				return
			end
			vim.fn.jobstart({ "open", url })
		end,

		mappings = {
			-- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
			["gf"] = {
				action = function()
					return require("obsidian").util.gf_passthrough()
				end,
				opts = { noremap = false, expr = true, buffer = true },
			},
			-- Toggle check-boxes.
			["<leader>tc"] = {
				action = function()
					return require("obsidian").util.toggle_checkbox()
				end,
				opts = { buffer = true, desc = "[T]oggle [C]heckbox" },
			},
			--
			-- Paste image.
			["<leader>it"] = {
				action = ":ObsidianTemplate<cr>",
				opts = { buffer = true, desc = "[I]nsert [T]emplate" },
			},

			-- Paste image.
			["<leader>ii"] = {
				action = ":ObsidianPasteImg<cr>",
				opts = { buffer = true, desc = "[I]nsert [I]mage" },
			},

			-- Insert link.
			["<leader>ill"] = {
				action = ":ObsidianLink<cr>",
				opts = { buffer = true, desc = "[I]nsert [L]ink" },
			},

			-- Open telescope links for current file
			["<leader>sl"] = {
				action = ":ObsidianLinks<cr>",
				opts = { buffer = true, desc = "[S]earch [L]inks" },
			},

			-- Open telescope backlinks for current file
			["<leader>sb"] = {
				action = ":ObsidianBacklinks<cr>",
				opts = { buffer = true, desc = "[S]earch [B]acklinks" },
			},

			-- Open telescope for all occurences of given tags
			["<leader>st"] = {
				action = ":ObsidianTags<cr>",
				opts = { buffer = true, desc = "[S]earch [T]ags" },
			},

			-- Open telescope for headings of current file
			["<leader>sc"] = {
				action = ":ObsidianTOC<cr>",
				opts = { buffer = true, desc = "[S]earch [C]urrent file headings" },
			},

			-- Smart action depending on context, either follow link or toggle checkbox.
			["<cr>"] = {
				action = function()
					return require("obsidian").util.smart_action()
				end,
				opts = { buffer = true, expr = true },
			},
		},
	},

	vim.keymap.set("v", "<leader>iln", ":ObsidianLinkNew<cr>", { desc = "[I]nsert [L]ink [N]ew" }),
	vim.keymap.set("v", "<leader>ill", ":ObsidianLink<cr>", { desc = "[I]nsert [L]ink" }),
	-- Open telescope to search for notes in vault.
	-- defined outside of mappings so that it can be accessed before the plugin is loaded.
	vim.keymap.set("n", "<leader>so", ":ObsidianSearch<cr>", { desc = "[S]earch [O]bsidian" }),
}

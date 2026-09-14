vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" })

require("gitsigns").setup({
	signs = {
		add = { text = "+" },
		change = { text = "~" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
	},
	on_attach = function(bufnr)
		local gitsigns = require("gitsigns")

		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		-- Navigation
		map("n", "]c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]c", bang = true })
			else
				gitsigns.nav_hunk("next")
			end
		end)

		map("n", "[c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[c", bang = true })
			else
				gitsigns.nav_hunk("prev")
			end
		end)

		-- Actions
		map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "stage hunk" })
		map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "reset hunk" })

		map("v", "<leader>hs", function()
			gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "stage hunk" })

		map("v", "<leader>hr", function()
			gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "reset hunk" })

		map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "stage buffer" })
		map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "reset buffer" })
		map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "preview hunk" })
		map("n", "<leader>hi", gitsigns.preview_hunk_inline, { desc = "preview hunk inline" })

		map("n", "<leader>hb", function()
			gitsigns.blame_line({ full = true })
		end, { desc = "blame line" })

		map("n", "<leader>hd", gitsigns.diffthis, { desc = "diff buffer" })

		map("n", "<leader>hD", function()
			gitsigns.diffthis("~")
		end, { desc = "diff ALL" })

		map("n", "<leader>hQ", function()
			gitsigns.setqflist("all")
		end, { desc = "add ALL hunks to qf" })
		map("n", "<leader>hq", gitsigns.setqflist, { desc = "add hunks to qf" })

		-- Toggles
		map("n", "<leader>xb", gitsigns.toggle_current_line_blame, { desc = "toggle blame" })
		map("n", "<leader>xw", gitsigns.toggle_word_diff, { desc = "toggle word diff" })

		-- Text object
		map({ "o", "x" }, "ih", gitsigns.select_hunk)
	end,
})

return { -- Useful plugin to show you pending keybinds.
	"folke/which-key.nvim",
	event = "VeryLazy",
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
	config = function() -- This is the function that runs, AFTER loading
		require("which-key").setup()

		-- Document existing key chains
		require("which-key").add({
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
		})
	end,
}

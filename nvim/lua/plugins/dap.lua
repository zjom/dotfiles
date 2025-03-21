return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"leoluz/nvim-dap-go",
		"rcarriga/nvim-dap-ui",
		"theHamsta/nvim-dap-virtual-text",
		"nvim-neotest/nvim-nio",
	},
	config = function()
		local dap = require("dap")
		local ui = require("dapui")
		require("dapui").setup()
		require("dap-go").setup()

		require("nvim-dap-virtual-text").setup()

		vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: [D]ap toggle [B]reakpoint" })
		vim.keymap.set("n", "<leader>dc", dap.run_to_cursor, { desc = "DAP: [D]ap run to [C]ursor" })
		-- Eval under cursor
		vim.keymap.set("n", "<leader>d<space>", function()
			require("dapui").eval(nil, { enter = true })
		end)

		vim.keymap.set("n", "<F1>", dap.continue, { desc = "DAP: continue" })
		vim.keymap.set("n", "<F2>", dap.step_into, { desc = "DAP: step into" })
		vim.keymap.set("n", "<F3>", dap.step_over, { desc = "DAP: step over" })
		vim.keymap.set("n", "<F4>", dap.step_out, { desc = "DAP: step out" })
		vim.keymap.set("n", "<F5>", dap.step_back, { desc = "DAP: step back" })
		vim.keymap.set("n", "<F12>", dap.restart, { desc = "DAP: restart" })

		dap.listeners.before.attach.dapui_config = function()
			ui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			ui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			ui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			ui.close()
		end
	end,
}

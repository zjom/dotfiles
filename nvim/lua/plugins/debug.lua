vim.pack.add({
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/igorlfs/nvim-dap-view",
})

local dap = require("dap")
dap.adapters.gdb = {
  type = "executable",
  command = "gdb",
  args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
}
dap.configurations.c = {
  {
    name = "Launch",
    type = "gdb",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    args = {}, -- provide arguments if needed
    cwd = "${workspaceFolder}",
    stopAtBeginningOfMainSubprogram = false,
  },
  {
    name = "Select and attach to process",
    type = "gdb",
    request = "attach",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    pid = function()
      local name = vim.fn.input('Executable name (filter): ')
      return require("dap.utils").pick_process({ filter = name })
    end,
    cwd = '${workspaceFolder}'
  },
  {
    name = 'Attach to gdbserver :1234',
    type = 'gdb',
    request = 'attach',
    target = 'localhost:1234',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}'
  }
}
dap.configurations.cpp = dap.configurations.c
dap.configurations.rust = dap.configurations.c

dap.listeners.after["event_initialized"]["zjom"] = function(_session, _body)
  vim.keymap.set("n", "<left>", "<cmd>DapStepOut<cr>")
  vim.keymap.set("n", "<up>", "<cmd>DapRestartFrame<cr>")
  vim.keymap.set("n", "<right>", "<cmd>DapStepInto<cr>")
  vim.keymap.set("n", "<down>", "<cmd>DapStepOver<cr>")
end


vim.keymap.set("n", "<F2>", "<cmd>DapToggleBreakpoint<cr>", { desc = "[D]ap toggle [B]reakpoint" })
vim.keymap.set("n", "<F5>", "<cmd>DapContinue<cr>", { desc = "[D]ap [C]ontinue" })
vim.keymap.set("n", "<leader>dv", "<cmd>DapViewOpen<cr>", { desc = "[D]ap [V]iew" })

---@diagnostic disable: undefined-field
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

local saved = {}

local function set_temp(mode, lhs, rhs)
  saved[#saved + 1] = vim.fn.maparg(lhs, mode, false, true) -- dict, may be empty
  saved[#saved].__lhs, saved[#saved].__mode = lhs, mode
  vim.keymap.set(mode, lhs, rhs)
end

local function restore()
  for _, m in ipairs(saved) do
    if m.rhs or m.callback then
      vim.fn.mapset(m.__mode, false, m)        -- put the original back
    else
      pcall(vim.keymap.del, m.__mode, m.__lhs) -- there wasn't one
    end
  end
  saved = {}
end
dap.listeners.after.event_initialized["zjom"] = function()
  set_temp("n", "<up>", dap.restart_frame)
  set_temp("n", "<left>", dap.step_out)
  set_temp("n", "<right>", dap.step_into)
  set_temp("n", "<down>", dap.step_over)
  set_temp("n", "<D-b>", dap.toggle_breakpoint)
  set_temp("n", "<D-o>", dap.step_over)
  set_temp("n", "<D-i>", dap.step_into)
  set_temp("n", "<D-r>", dap.restart_frame)
  set_temp("n", "<D-u>", dap.continue)
end

dap.listeners.before.event_terminated["zjom"] = restore
dap.listeners.before.event_exited["zjom"] = restore


vim.keymap.set("n", "<F2>", "<cmd>DapToggleBreakpoint<cr>", { desc = "[D]ap toggle [B]reakpoint" })
vim.keymap.set("n", "<F5>", "<cmd>DapContinue<cr>", { desc = "[D]ap [C]ontinue" })
vim.keymap.set("n", "<leader>dv", "<cmd>DapViewOpen<cr>", { desc = "[D]ap [V]iew" })

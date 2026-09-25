vim.pack.add({ "https://github.com/zjom/snot.nvim" })
local snot = require("snot")

vim.keymap.set("n", "<leader>pd", function()
  snot.goto_daily({ cmd = "split" })
end, { desc = "snot [D]aily" })

vim.keymap.set("n", "<leader>pN", function()
  vim.ui.input({
    prompt = "Enter note title: ",
  }, function(title)
    snot.create_note({ title = title })
  end)
end, { desc = "snot [N]ew" })

vim.keymap.set("n", "<leader>pf", function()
  require('telescope.builtin').find_files({
    cwd = snot.directory()
  })
end, { desc = "snot [F]ind" })

vim.keymap.set("n", "<leader>ps", function()
  require('telescope.builtin').live_grep({
    cwd = snot.directory()
  })
end, { desc = "snot [S]earch" })

vim.keymap.set("n", "<leader>pt", "<Plug>(snot-tag)", { desc = "snot [T]ag" })

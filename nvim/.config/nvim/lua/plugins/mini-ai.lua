-- Better Around/Inside textobjects
--
-- Examples:
--  - va)  - [V]isually select [A]round [)]parenthen
--  - yinq - [Y]ank [I]nside [N]ext [']quote
--  - ci'  - [C]hange [I]nside [']quote
return {
	"nvim-mini/mini.ai",
	config = function()
		require("mini.ai").setup({
			n_lines = 500,
		})
	end,
	event = "BufWinEnter",
}

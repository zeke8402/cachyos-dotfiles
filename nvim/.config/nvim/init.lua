-- Set leader FIRST
vim.g.mapleader = " "

-- Custom Keymappings ZEKE
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	-- Plugins go here
	"nvim-lua/plenary.nvim",
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("telescope").setup({
				pickers = {
					colorscheme = {
						enable_preview = true,
					},
				},
			})
		end
	},

	-- Some popular themes to browse
	"catppuccin/nvim",
	"folke/tokyonight.nvim",
	"rebelot/kanagawa.nvim",
	"EdenEast/nightfox.nvim",
	{
		"nvim-tree/nvim-tree.lua",
		config = function()
			require("nvim-tree").setup()
		end,
	},
	"nvim-tree/nvim-web-devicons",
})

return {
	{
		"mason-org/mason.nvim",
		opts = {
			ensure_installed = {
				"lua-language-server",
				"stylua",
				"bash-language-server",
				"shellcheck",
				"shfmt",
				"clang-format",
			},
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				"bash",
				"lua",
				"json",
				"jq",
				"markdown",
				"markdown_inline",
				"regex",
				"vim",
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		opts = {
			setup = {
				clangd = function(_, opts)
					opts.capabilities.offsetEncoding = { "utf-16" }
				end,
			},
		},
	},
	{
		"ThePrimeagen/refactoring.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("refactoring").setup({})
		end,
	},
	{
		"sphamba/smear-cursor.nvim",
		opts = {
			cursor_color = "none",
			hide_target_hack = true,
		},
	},
	{
		"nvim-mini/mini.icons",
		opts = {
			style = "nerd",
		},
	},
	{
		"nvim-tree/nvim-web-devicons",
		opts = {
			default = true,
		},
	},
	{
		"mfussenegger/nvim-lint",
		opts = {
			linters_by_ft = {
				c = { "coccinelle", "infer" },
				cpp = { "coccinelle", "infer" },
			},
		},
	},
}

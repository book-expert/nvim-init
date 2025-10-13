-- Author: Niko
-- Single-file Neovim configuration using lazy.nvim.
-- Optimized for C/Go with a vibrant neon tokyonight theme.

----------------------------------------------------------------------
-- 1. Leader keys & core options
----------------------------------------------------------------------

vim.g.mapleader = " "
vim.g.maplocalleader = ","

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.wrap = false
opt.breakindent = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.signcolumn = "yes"
opt.termguicolors = true
opt.completeopt = { "menu", "menuone", "noselect" }
opt.undofile = true
opt.backup = false
opt.swapfile = false
opt.updatetime = 250
opt.timeoutlen = 300
opt.splitright = true
opt.splitbelow = true
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.cursorline = true

vim.cmd("filetype plugin indent on")

----------------------------------------------------------------------
-- 2. Bootstrap lazy.nvim
----------------------------------------------------------------------

local uv = vim.uv or vim.loop
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end
opt.rtp:prepend(lazypath)

----------------------------------------------------------------------
-- 3. Autocmds
----------------------------------------------------------------------

local aug = vim.api.nvim_create_augroup
local auc = vim.api.nvim_create_autocmd
local group = aug("CustomAutocmds", { clear = true })

-- Kernel/UEFI 8-space C style
auc("FileType", {
	group = group,
	pattern = "c",
	callback = function()
		vim.bo.shiftwidth = 8
		vim.bo.tabstop = 8
		vim.bo.softtabstop = 8
		vim.bo.expandtab = false
	end,
})

-- Highlight on yank
auc("TextYankPost", {
	group = group,
	callback = function()
		vim.highlight.on_yank({ timeout = 200 })
	end,
})

-- Auto-create missing dirs on save
auc("BufWritePre", {
	group = group,
	callback = function(ev)
		if ev.match:match("^%w+://") then
			return
		end
		local file = uv.fs_realpath(ev.match) or ev.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- q to close helper buffers
auc("FileType", {
	group = group,
	pattern = {
		"PlenaryTestPopup",
		"help",
		"lspinfo",
		"notify",
		"qf",
		"spectre_panel",
		"startuptime",
		"tsplayground",
		"neotest-output",
		"checkhealth",
		"neotest-summary",
		"neotest-output-panel",
		"dbout",
		"gitsigns.blame",
	},
	callback = function(ev)
		vim.bo[ev.buf].buflisted = false
		vim.keymap.set("n", "q", "close", { buffer = ev.buf, silent = true })
	end,
})

-- LSP keymaps via LspAttach (0.11+ preferred over on_attach)
local lsp_group = aug("LspKeymaps", { clear = true })
auc("LspAttach", {
	group = lsp_group,
	callback = function(args)
		local o = { buffer = args.buf, silent = true }
		local map = vim.keymap.set
		map("n", "gD", vim.lsp.buf.declaration, o)
		map("n", "gd", vim.lsp.buf.definition, o)
		map("n", "K", vim.lsp.buf.hover, o)
		map("n", "gi", vim.lsp.buf.implementation, o)
		map("n", "gs", vim.lsp.buf.signature_help, o)
		map("n", "<leader>rn", vim.lsp.buf.rename, o)
		map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, o)
		map("n", "gr", vim.lsp.buf.references, o)
		map("n", "gl", vim.diagnostic.open_float, o)
	end,
})

----------------------------------------------------------------------
-- 4. Keymaps
----------------------------------------------------------------------

local map = vim.keymap.set
-- Quick escape and clear search
map("i", "jk", "<Esc>", { desc = "Exit insert", silent = true })
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search", silent = true })
-- Window navigation
map("n", "<C-h>", "<C-w>h", { silent = true })
map("n", "<C-j>", "<C-w>j", { silent = true })
map("n", "<C-k>", "<C-w>k", { silent = true })
map("n", "<C-l>", "<C-w>l", { silent = true })
-- File tree
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "File explorer", silent = true })

----------------------------------------------------------------------
-- 5. Plugins (lazy.nvim)
----------------------------------------------------------------------

require("lazy").setup({

	-- Lua typing helpers
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } },
		},
	},

	-- which-key
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {},
	},

	-- Treesitter: load at startup and ensure Lua parser exists (fixes ftplugin/lua.lua error)
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			-- Synchronous update/installation so Lua parser is available before ftplugin runs
			pcall(function()
				local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
				ts_update()
			end)
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"lua",
					"c",
					"cpp",
					"go",
					"rust",
					"python",
					"bash",
					"json",
					"yaml",
					"toml",
					"html",
					"css",
					"markdown",
					"javascript",
					"typescript",
					"make",
					"kconfig",
					"devicetree",
					"linkerscript",
					"asm",
				},
				highlight = { enable = true },
				indent = { enable = true },
				sync_install = false,
				auto_install = true,
			})
		end,
	},

	-- Rainbow parentheses (proper setup entrypoint)
	{
		"HiPhish/rainbow-delimiters.nvim",
		event = { "BufReadPost", "BufNewFile" },
		main = "rainbow-delimiters.setup",
		opts = {
			highlight = {
				"RainbowDelimiterRed",
				"RainbowDelimiterYellow",
				"RainbowDelimiterBlue",
				"RainbowDelimiterOrange",
				"RainbowDelimiterGreen",
				"RainbowDelimiterViolet",
				"RainbowDelimiterCyan",
			},
		},
	},

	-- Oil (file explorer alternative)
	{
		"stevearc/oil.nvim",
		dependencies = { { "echasnovski/mini.icons", opts = {} } },
		opts = {
			default_file_explorer = true,
			columns = { "icon" },
			float = { border = "rounded" },
			confirmation = { border = "rounded" },
			progress = { border = "rounded" },
			ssh = { border = "rounded" },
			keymaps_help = { border = "rounded" },
			view_options = { show_hidden = false, natural_order = "fast" },
		},
	},

	-- NvimTree (kept for continuity)
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = "nvim-tree/nvim-web-devicons",
		opts = {
			disable_netrw = true,
			hijack_netrw = true,
			update_focused_file = { enable = true, update_root = true },
			view = { width = 30, side = "left", relativenumber = true, signcolumn = "yes" },
			renderer = {
				group_empty = true,
				highlight_git = true,
				icons = { show = { file = true, folder = true, git = true } },
			},
			git = { ignore = false, timeout = 400 },
		},
	},

	-- Notifications
	{
		"rcarriga/nvim-notify",
		config = function()
			require("notify").setup({ background_colour = "#000000" })
			vim.notify = require("notify")
		end,
	},

	-- Neon Tokyonight theme with Google-like rainbow accents
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		config = function()
			local P = {
				bg = "#0B0F14",
				surface = "#151A1F",
				fg = "#E6E9EF",
				fg_dim = "#B7C2CC",
				electric = "#00C8FF",
				gblue = "#4285F4",
				ggreen = "#34A853",
				gyellow = "#FABB05",
				gred = "#EA4335",
				teal = "#00BFA6",
				magenta = "#FF4D9A",
				orange = "#FF8A00",
			}

			require("tokyonight").setup({
				style = "night",
				on_colors = function(c)
					c.bg, c.bg_dark, c.bg_float, c.bg_highlight = P.bg, P.surface, P.surface, "#1A222A"
					c.fg, c.fg_dark = P.fg, P.fg_dim
					c.blue, c.cyan, c.teal = P.gblue, P.electric, P.teal
					c.yellow, c.orange, c.magenta = P.gyellow, P.orange, P.magenta
					c.red, c.green = P.gred, P.ggreen
				end,
				on_highlights = function(hl, c)
					-- Core UI
					hl.Normal = { fg = c.fg, bg = c.bg }
					hl.NormalFloat = { fg = c.fg, bg = c.bg_float }
					hl.FloatBorder = { fg = c.fg_dark, bg = c.bg_float }
					hl.SignColumn = { bg = c.bg }
					hl.LineNr = { fg = c.fg_dark }
					hl.CursorLine = { bg = c.bg_highlight }
					hl.CursorLineNr = { fg = c.fg }
					hl.Visual = { bg = "#2a2f3a" }
					hl.Search = { fg = c.bg, bg = P.gyellow }
					hl.IncSearch = { fg = c.bg, bg = P.orange }
					hl.MatchParen = { bold = true, fg = P.orange }

					-- Syntax accents
					hl["@number"] = { fg = P.electric, bold = true }
					hl["@float"] = { fg = P.electric, bold = true }
					hl["@constant"] = { fg = P.electric }
					hl.Number = { fg = P.electric, bold = true }
					hl.Float = { fg = P.electric, bold = true }
					hl.Boolean = { fg = P.electric, bold = true }
					hl.String = { fg = P.gyellow }
					hl.Character = { fg = P.gyellow }
					hl.Keyword = { fg = P.gblue }
					hl.Function = { fg = P.electric }
					hl.Type = { fg = P.gyellow }
					hl.Identifier = { fg = c.fg }

					-- Diagnostics
					hl.DiagnosticError = { fg = P.magenta }
					hl.DiagnosticWarn = { fg = P.orange }
					hl.DiagnosticInfo = { fg = P.gblue }
					hl.DiagnosticHint = { fg = P.teal }
					hl.DiagnosticOk = { fg = P.ggreen }
					hl.DiagnosticUnderlineError = { sp = P.magenta, undercurl = true }
					hl.DiagnosticUnderlineWarn = { sp = P.orange, undercurl = true }
					hl.DiagnosticUnderlineInfo = { sp = P.gblue, undercurl = true }
					hl.DiagnosticUnderlineHint = { sp = P.teal, undercurl = true }

					-- Git signs and diffs
					hl.GitSignsAdd = { fg = P.ggreen }
					hl.GitSignsChange = { fg = P.gyellow }
					hl.GitSignsDelete = { fg = P.magenta }
					hl.DiffAdd = { bg = "#092d23" }
					hl.DiffChange = { bg = "#2a240f" }
					hl.DiffDelete = { bg = "#2a0f20" }

					-- Telescope and NvimTree
					hl.TelescopeSelection = { bg = c.bg_highlight }
					hl.TelescopeBorder = { fg = c.fg_dark, bg = c.bg_float }
					hl.NvimTreeNormal = { bg = c.bg }
					hl.NvimTreeNormalNC = { bg = c.bg }
					hl.NvimTreeWinSeparator = { fg = c.bg, bg = c.bg }

					-- Rainbow-delimiters (neon rainbow)
					hl.RainbowDelimiterRed = { fg = P.gred }
					hl.RainbowDelimiterYellow = { fg = P.gyellow }
					hl.RainbowDelimiterBlue = { fg = P.gblue }
					hl.RainbowDelimiterOrange = { fg = P.orange }
					hl.RainbowDelimiterGreen = { fg = P.ggreen }
					hl.RainbowDelimiterViolet = { fg = P.magenta }
					hl.RainbowDelimiterCyan = { fg = P.electric }
				end,
			})

			vim.cmd("colorscheme tokyonight")

			-- Optional lualine palette if ever switching to custom theme table
			vim.g.niko_vibrant_lualine = {
				normal = {
					a = { fg = P.bg, bg = P.electric, gui = "bold" },
					b = { fg = P.fg, bg = P.surface },
					c = { fg = P.fg_dim, bg = P.bg },
				},
				insert = { a = { fg = P.bg, bg = P.ggreen, gui = "bold" } },
				visual = { a = { fg = P.bg, bg = P.orange, gui = "bold" } },
				replace = { a = { fg = P.bg, bg = P.magenta, gui = "bold" } },
				command = { a = { fg = P.bg, bg = P.gyellow, gui = "bold" } },
				inactive = {
					a = { fg = P.fg_dim, bg = P.bg },
					b = { fg = P.fg_dim, bg = P.bg },
					c = { fg = P.fg_dim, bg = P.bg },
				},
			}
		end,
	},

	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("lualine").setup({
				options = {
					theme = "tokyonight",
					component_separators = "|",
					section_separators = "",
					globalstatus = true,
				},
				sections = {
					lualine_x = {
						function()
							local ok, cc = pcall(require, "codecompanion.utils.actions")
							return (ok and cc.is_available()) and "🤖 CC" or ""
						end,
						"filetype",
						"encoding",
					},
				},
			})
		end,
	},

	-- Dashboard
	{
		"goolord/alpha-nvim",
		event = "VimEnter",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("alpha").setup(require("alpha.themes.startify").config)
		end,
	},

	-- Telescope (stable 0.1.x)
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = "nvim-lua/plenary.nvim",
		config = function()
			require("telescope").setup({
				defaults = {
					mappings = {
						i = {
							["<C-j>"] = "move_selection_next",
							["<C-k>"] = "move_selection_previous",
						},
					},
				},
			})
			local tb = require("telescope.builtin")
			map("n", "ff", tb.find_files, { desc = "Find files" })
			map("n", "fg", tb.live_grep, { desc = "Live grep" })
			map("n", "fb", tb.buffers, { desc = "Buffers" })
			map("n", "fh", tb.help_tags, { desc = "Help tags" })
		end,
	},

	-- Git signs
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPost", "BufNewFile" },
		opts = {},
	},

	------------------------------------------------------------------
	-- LSP / Formatting / Linting (0.11+ model)
	------------------------------------------------------------------

	-- Install servers/tools
	{ "williamboman/mason.nvim", build = ":MasonUpdate", opts = { ui = { border = "rounded" } } },

	-- Make lspconfig’s server configs available on the runtimepath (no legacy require needed)
	{ "neovim/nvim-lspconfig", lazy = false },

	-- Bridge Mason and the new vim.lsp.config/enable flow
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			local servers = { "lua_ls", "clangd", "bashls", "pyright", "gopls", "rust_analyzer" }
			require("mason-lspconfig").setup({
				ensure_installed = servers,
				automatic_enable = true, -- calls vim.lsp.enable() for installed servers
			})

			-- Capabilities for completion
			local caps = require("cmp_nvim_lsp").default_capabilities()

			-- Configure servers (must run before enable so automatic_enable picks these up)
			vim.lsp.config("lua_ls", {
				capabilities = caps,
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						diagnostics = { globals = { "vim" } },
						workspace = { library = vim.api.nvim_get_runtime_file("", true) },
					},
				},
			})

			vim.lsp.config("clangd", {
				capabilities = caps,
				cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--header-insertion=iwyu",
					"--completion-style=detailed",
					"--pch-storage=memory",
				},
			})

			vim.lsp.config("gopls", {
				capabilities = caps,
				settings = {
					gopls = {
						usePlaceholders = true,
						completeUnimported = true,
						staticcheck = true,
						gofumpt = true,
						analyses = { unusedparams = true, nilness = true, shadow = true },
						codelenses = { generate = true, gc_details = true, test = true, tidy = true },
						hints = {
							rangeVariableTypes = true,
							parameterNames = true,
							assignVariableTypes = true,
							functionTypeParameters = true,
						},
						directoryFilters = { "-**/vendor" },
					},
				},
			})

			-- Default configs with capabilities
			for _, srv in ipairs({ "bashls", "pyright", "rust_analyzer" }) do
				vim.lsp.config(srv, { capabilities = caps })
			end

			-- Fallback enable for non-Mason servers (noop if automatic_enable already enabled them)
			vim.schedule(function()
				for _, srv in ipairs({ "lua_ls", "clangd", "bashls", "pyright", "gopls", "rust_analyzer" }) do
					pcall(vim.lsp.enable, srv)
				end
			end)
		end,
		dependencies = { "williamboman/mason.nvim", "hrsh7th/cmp-nvim-lsp" },
	},

	-- Conform (formatting)
	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		dependencies = "williamboman/mason.nvim",
		config = function()
			require("conform").setup({
				format_on_save = function(bufnr)
					if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
						return
					end
					return { timeout_ms = 500, lsp_fallback = true }
				end,
				formatters_by_ft = {
					c = { "clang-format" },
					cpp = { "clang-format" },
					lua = { "stylua" },
					bash = { "shfmt" },
					sh = { "shfmt" },
					python = { "isort", "black" },
					javascript = { "prettier" },
					typescript = { "prettier" },
					javascriptreact = { "prettier" },
					typescriptreact = { "prettier" },
					json = { "prettier" },
					yaml = { "prettier" },
					html = { "prettier" },
					css = { "prettier" },
					scss = { "prettier" },
					go = { "gofumpt", "goimports", "golines" },
				},
				formatters = {
					prettier = { prepend_args = { "--no-config", "--tab-width", "2", "--single-quote" } },
					["clang-format"] = { prepend_args = { "--style", "Linux" } },
					golines = { prepend_args = { "--max-len", "100" } },
				},
			})

			map({ "n", "v" }, "<leader>mp", function()
				require("conform").format({ lsp_fallback = true, timeout_ms = 500 })
			end, { desc = "Format file/range" })
		end,
	},

	-- nvim-lint (with checkpatch and Go)
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPost", "BufWritePost" },
		dependencies = "williamboman/mason.nvim",
		config = function()
			local lint = require("lint")

			-- custom kernel checkpatch linter
			lint.linters.checkpatch = {
				cmd = "checkpatch.pl",
				args = { "--no-tree", "--file", "-" },
				stdin = true,
				ignore_exitcode = true,
				parser = function(out)
					local diags = {}
					for _, line in ipairs(vim.split(out, "\n", { plain = true })) do
						local m = vim.fn.matchlist(line, [[\v^([^:]+):(\d+):\s*(ERROR|WARNING|CHECK):\s*(.*)]])
						if #m > 0 then
							local sev = m[3]
							local severity = (sev == "ERROR" and vim.diagnostic.severity.ERROR)
								or (sev == "WARNING" and vim.diagnostic.severity.WARN)
								or vim.diagnostic.severity.INFO
							table.insert(diags, {
								lnum = tonumber(m[2]) - 1,
								col = 0,
								severity = severity,
								message = m[4],
								source = "checkpatch",
							})
						end
					end
					return diags
				end,
			}

			lint.linters_by_ft = {
				c = { "checkpatch" },
				sh = { "shellcheck" },
				bash = { "shellcheck" },
				python = { "pylint" },
				javascript = { "eslint_d" },
				typescript = { "eslint_d" },
				javascriptreact = { "eslint_d" },
				typescriptreact = { "eslint_d" },
				go = { "golangcilint" },
			}

			local lint_group = vim.api.nvim_create_augroup("Linting", { clear = true })
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
				group = lint_group,
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},

	-- Trouble (v3 key syntax)
	{
		"folke/trouble.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		keys = {
			{ "xx", "Trouble diagnostics toggle", desc = "Trouble" },
			{ "xw", "Trouble diagnostics toggle focus=false filter.buf=0", desc = "Workspace diags" },
		},
	},

	------------------------------------------------------------------
	-- Completion
	------------------------------------------------------------------

	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"onsails/lspkind.nvim",
			"rafamadriz/friendly-snippets",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local lspkind = require("lspkind")
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				}),
				formatting = { format = lspkind.cmp_format({ mode = "symbol_text", maxwidth = 50 }) },
			})
		end,
	},

	------------------------------------------------------------------
	-- Editing utilities
	------------------------------------------------------------------

	{ "numToStr/Comment.nvim", opts = {} },

	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {},
	},

	{
		"OXY2DEV/markview.nvim",
		lazy = true,
		dependencies = "nvim-treesitter/nvim-treesitter",
		opts = { experimental = { check_rtp_message = false } },
	},

	-- Indent guides (ibl)
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = { indent = { char = "┊" }, scope = { enabled = false } },
	},

	-- HTML/TSX autotag
	{
		"windwp/nvim-ts-autotag",
		event = { "InsertEnter", "BufReadPre", "BufNewFile" },
		opts = {},
	},

	-- Extra syntax
	{ "ggml-org/llama.vim" },

	------------------------------------------------------------------
	-- Debugging (DAP)
	------------------------------------------------------------------

	{
		"mfussenegger/nvim-dap",
		dependencies = { "rcarriga/nvim-dap-ui", "nvim-neotest/nvim-nio", "williamboman/mason.nvim" },
		config = function()
			local dap, dapui = require("dap"), require("dapui")
			dapui.setup()
			dap.listeners.after.event_initialized["dapui"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui"] = function()
				dapui.close()
			end

			map("n", "db", dap.toggle_breakpoint, { desc = "Breakpoint" })
			map("n", "dc", dap.continue, { desc = "Continue" })
			map("n", "do", dap.step_over, { desc = "Step over" })
			map("n", "di", dap.step_into, { desc = "Step into" })
			map("n", "du", dap.step_out, { desc = "Step out" })
			map("n", "dr", dap.repl.open, { desc = "REPL" })

			-- C/C++/Rust via codelldb
			dap.adapters.codelldb = {
				type = "server",
				port = "${port}",
				executable = { command = "codelldb", args = { "--port", "${port}" } },
			}

			local cfg = {
				name = "Launch file",
				type = "codelldb",
				request = "launch",
				program = function()
					return vim.fn.input("Path to exe: ", vim.fn.getcwd() .. "/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
			}

			dap.configurations.c = { cfg }
			dap.configurations.cpp = { cfg }
			dap.configurations.rust = { cfg }
		end,
	},

	{
		"leoluz/nvim-dap-go",
		ft = { "go" },
		dependencies = { "mfussenegger/nvim-dap" },
		config = function()
			require("dap-go").setup()
			map("n", "dgt", function()
				require("dap-go").debug_test()
			end, { desc = "Debug Go test" })
			map("n", "dgl", function()
				require("dap-go").debug_last_test()
			end, { desc = "Debug last Go test" })
		end,
	},

	{
		"ray-x/go.nvim",
		ft = { "go", "gomod", "gowork", "gotmpl" },
		dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter", "neovim/nvim-lspconfig" },
		opts = {
			lsp_cfg = false,
			lsp_inlay_hints = { enable = true },
			trouble = true,
			run_in_floaterm = true,
		},
	},
}, {
	ui = { border = "rounded" },
	checker = { enabled = true, notify = false },
	change_detection = { notify = false },
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"matchit",
				"matchparen",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})

----------------------------------------------------------------

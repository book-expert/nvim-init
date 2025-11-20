-- Author: Niko
-- Single-file Neovim configuration.
-- Focus: Go, Python, Bash, Lua, TOML, YAML, C (Kernel/UEFI).
-- Theme: Vibrant Google Pastel on Dark.

----------------------------------------------------------------------
-- 1. Options
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
opt.updatetime = 250
opt.timeoutlen = 300
opt.splitright = true
opt.splitbelow = true
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.cursorline = true

----------------------------------------------------------------------
-- 2. Lazy.nvim Bootstrap
----------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath,
    })
end
opt.rtp:prepend(lazypath)

----------------------------------------------------------------------
-- 3. Autocmds
----------------------------------------------------------------------
local aug = vim.api.nvim_create_augroup
local auc = vim.api.nvim_create_autocmd
local group = aug("NikoConfig", { clear = true })

-- Kernel/UEFI 8-space C style
auc("FileType", {
    group = group,
    pattern = { "c", "cpp", "make" },
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
    callback = function() vim.highlight.on_yank({ timeout = 200 }) end,
})

-- Auto-create dirs on save
auc("BufWritePre", {
    group = group,
    callback = function(ev)
        if ev.match:match("^%w+://") then return end
        local file = vim.uv.fs_realpath(ev.match) or ev.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end,
})

----------------------------------------------------------------------
-- 4. Keymaps
----------------------------------------------------------------------
local map = vim.keymap.set
map("i", "jk", "<Esc>", { desc = "Exit insert", silent = true })
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search", silent = true })
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "File explorer", silent = true })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { silent = true })
map("n", "<C-j>", "<C-w>j", { silent = true })
map("n", "<C-k>", "<C-w>k", { silent = true })
map("n", "<C-l>", "<C-w>l", { silent = true })

----------------------------------------------------------------------
-- 5. Plugins
----------------------------------------------------------------------
require("lazy").setup({

    -- Lua Library for Neovim
    { "folke/lazydev.nvim", ft = "lua", opts = {} },

    -- Key helpers
    { "folke/which-key.nvim", event = "VeryLazy", opts = {} },

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "lua", "python", "go", "gomod", "bash", "toml", "yaml", "json",
                    "c", "make", "kconfig", "devicetree", "markdown", "markdown_inline"
                },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },

    -- Rainbow Delimiters (Google Palette)
    {
        "HiPhish/rainbow-delimiters.nvim",
        event = "BufReadPost",
        config = function()
            local rainbow_delimiters = require("rainbow-delimiters")
            vim.g.rainbow_delimiters = {
                strategy = { [""] = rainbow_delimiters.strategy["global"] },
                query = { [""] = "rainbow-delimiters" },
                highlight = {
                    "RainbowDelimiterBlue",
                    "RainbowDelimiterRed",
                    "RainbowDelimiterYellow",
                    "RainbowDelimiterGreen",
                    "RainbowDelimiterViolet",
                    "RainbowDelimiterCyan",
                },
            }
        end,
    },

    -- Icons
    { "echasnovski/mini.icons", opts = {} },

    -- File Explorer
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = "echasnovski/mini.icons",
        opts = {
            disable_netrw = true,
            hijack_netrw = true,
            view = { width = 30 },
            git = { ignore = false },
            renderer = { group_empty = true, icons = { show = { git = true } } },
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

    -- THEME: Google Vibrant Pastel
    {
        "folke/tokyonight.nvim",
        priority = 1000,
        config = function()
            -- Google Brand Colors -> Pastel-ified for Dark Mode
            local G = {
                blue    = "#8AB4F8", -- Google Blue Light
                red     = "#F28B82", -- Google Red Light
                yellow  = "#FDD663", -- Google Yellow Light
                green   = "#81C995", -- Google Green Light
                bg      = "#131519", -- Deep Matte Dark
                bg_alt  = "#1B1E23",
                fg      = "#E8EAED",
                comment = "#757C85",
                magenta = "#FF7EB6", -- Vibrant accent
                cyan    = "#78D9EA", -- Vibrant accent
            }

            require("tokyonight").setup({
                style = "night",
                transparent = false,
                terminal_colors = true,
                styles = {
                    comments = { italic = true },
                    keywords = { italic = true },
                    functions = { bold = true },
                    variables = {},
                },
                on_colors = function(c)
                    c.bg = G.bg
                    c.bg_dark = G.bg
                    c.bg_float = G.bg_alt
                    c.bg_sidebar = G.bg_alt
                    c.fg = G.fg
                    c.fg_dark = G.comment
                    
                    -- Mapping Google Palette
                    c.blue = G.blue
                    c.cyan = G.cyan
                    c.green = G.green
                    c.orange = G.yellow -- Mapping yellow to orange slot for vibrancy
                    c.magenta = G.magenta
                    c.red = G.red
                    c.teal = G.cyan
                    c.yellow = G.yellow
                end,
                on_highlights = function(hl, c)
                    -- UI Overrides
                    hl.LineNr = { fg = G.comment }
                    hl.CursorLineNr = { fg = G.blue, bold = true }
                    hl.CursorLine = { bg = "#20242A" }
                    hl.Visual = { bg = "#3C4043" } -- Google Grey 700
                    hl.Search = { fg = G.bg, bg = G.yellow, bold = true }
                    hl.IncSearch = { fg = G.bg, bg = G.blue, bold = true }
                    
                    -- Syntax Overrides (Vibrant)
                    hl.Comment = { fg = G.comment, italic = true }
                    hl.Keyword = { fg = G.blue, italic = true }
                    hl.Function = { fg = G.green, bold = true }
                    hl.String = { fg = G.yellow }
                    hl.Number = { fg = G.red }
                    hl.Boolean = { fg = G.red, bold = true }
                    hl.Type = { fg = G.cyan }
                    hl.Identifier = { fg = G.fg }
                    hl.Constant = { fg = G.magenta }
                    
                    -- Rainbow Delimiters Matching
                    hl.RainbowDelimiterBlue = { fg = G.blue }
                    hl.RainbowDelimiterRed = { fg = G.red }
                    hl.RainbowDelimiterYellow = { fg = G.yellow }
                    hl.RainbowDelimiterGreen = { fg = G.green }
                    hl.RainbowDelimiterViolet = { fg = G.magenta }
                    hl.RainbowDelimiterCyan = { fg = G.cyan }
                    
                    -- Git Signs
                    hl.GitSignsAdd = { fg = G.green }
                    hl.GitSignsChange = { fg = G.blue }
                    hl.GitSignsDelete = { fg = G.red }
                end,
            })
            vim.cmd("colorscheme tokyonight")
        end,
    },

    -- Statusline (Lualine)
    {
        "nvim-lualine/lualine.nvim",
        dependencies = "echasnovski/mini.icons",
        opts = {
            options = {
                theme = "tokyonight",
                component_separators = "|",
                section_separators = "",
                globalstatus = true,
            },
        },
    },

    -- Telescope
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = "nvim-lua/plenary.nvim",
        config = function()
            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "ff", builtin.find_files, { desc = "Find Files" })
            vim.keymap.set("n", "fg", builtin.live_grep, { desc = "Live Grep" })
            vim.keymap.set("n", "fb", builtin.buffers, { desc = "Buffers" })
            vim.keymap.set("n", "fh", builtin.help_tags, { desc = "Help" })
        end,
    },

    -- Git Signs
    { "lewis6991/gitsigns.nvim", opts = {} },

    -- Utils
    { "numToStr/Comment.nvim", opts = {} },
    { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
    { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = { scope = { enabled = false } } },
    { "OXY2DEV/markview.nvim", ft = "markdown", opts = {} },

    ------------------------------------------------------------------
    -- LSP / Formatting / Linting
    ------------------------------------------------------------------
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            require("mason").setup({ ui = { border = "rounded" } })
            
            -- Relevant servers for your stack
            local servers = { "gopls", "pyright", "bashls", "lua_ls", "yamlls", "taplo" }
            
            require("mason-lspconfig").setup({
                ensure_installed = servers,
                automatic_enable = true,
            })

            local caps = require("cmp_nvim_lsp").default_capabilities()
            local lspconfig = require("lspconfig")

            -- General setup
            for _, server in ipairs(servers) do
                if server ~= "lua_ls" and server ~= "gopls" then
                    lspconfig[server].setup({ capabilities = caps })
                end
            end

            -- Lua specific
            lspconfig.lua_ls.setup({
                capabilities = caps,
                settings = { Lua = { diagnostics = { globals = { "vim" } } } },
            })

            -- Go specific
            lspconfig.gopls.setup({
                capabilities = caps,
                settings = {
                    gopls = {
                        usePlaceholders = true,
                        completeUnimported = true,
                        staticcheck = true,
                        analyses = { unusedparams = true },
                    },
                },
            })

            -- Kernel/C specific (Manual setup, assuming system clangd or added manually)
            lspconfig.clangd.setup({
                capabilities = caps,
                cmd = { "clangd", "--background-index", "--clang-tidy" }
            })

            -- Keymaps
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                callback = function(ev)
                    local opts = { buffer = ev.buf, silent = true }
                    local m = vim.keymap.set
                    m("n", "gd", vim.lsp.buf.definition, opts)
                    m("n", "K", vim.lsp.buf.hover, opts)
                    m("n", "<leader>rn", vim.lsp.buf.rename, opts)
                    m({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
                    m("n", "gr", vim.lsp.buf.references, opts)
                end,
            })
        end,
    },

    -- Formatting (Conform)
    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        opts = {
            format_on_save = { timeout_ms = 500, lsp_fallback = true },
            formatters_by_ft = {
                lua = { "stylua" },
                python = { "isort", "black" },
                go = { "gofumpt", "goimports" },
                bash = { "shfmt" },
                yaml = { "prettier" }, -- Prettier is good for YAML/Markdown
                json = { "prettier" },
                toml = { "taplo" },
            },
        },
    },

    -- Linting (nvim-lint)
    {
        "mfussenegger/nvim-lint",
        event = { "BufWritePost" },
        config = function()
            local lint = require("lint")
            
            -- Custom Kernel Checkpatch
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
                            local sev = (m[3] == "ERROR" and vim.diagnostic.severity.ERROR) or vim.diagnostic.severity.WARN
                            table.insert(diags, {
                                lnum = tonumber(m[2]) - 1,
                                col = 0,
                                severity = sev,
                                message = m[4],
                                source = "checkpatch",
                            })
                        end
                    end
                    return diags
                end,
            }

            lint.linters_by_ft = {
                python = { "pylint" },
                bash = { "shellcheck" },
                go = { "golangcilint" },
                c = { "checkpatch" },
            }

            vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
                callback = function() lint.try_lint() end,
            })
        end,
    },

    -- Completion
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "onsails/lspkind.nvim",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            cmp.setup({
                snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
                        else fallback() end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                }),
                formatting = {
                    format = require("lspkind").cmp_format({ mode = "symbol", maxwidth = 50 })
                },
            })
        end,
    },
    
    -- Go Tools
    {
        "ray-x/go.nvim",
        dependencies = {  "ray-x/guihua.lua", "neovim/nvim-lspconfig", "nvim-treesitter/nvim-treesitter" },
        config = function() require("go").setup() end,
        event = {"CmdlineEnter"},
        ft = {"go", 'gomod'},
    },
    
    -- Debugging (DAP)
    {
        "mfussenegger/nvim-dap",
        dependencies = { "rcarriga/nvim-dap-ui", "nvim-neotest/nvim-nio" },
        config = function()
            local dap, dapui = require("dap"), require("dapui")
            dapui.setup()
            dap.listeners.after.event_initialized["dapui"] = function() dapui.open() end
            dap.listeners.before.event_terminated["dapui"] = function() dapui.close() end
            dap.listeners.before.event_exited["dapui"] = function() dapui.close() end
            
            -- Go Debugging
            require("dap-go").setup()
        end,
    },
    { "leoluz/nvim-dap-go", ft = "go" },

}, {
    ui = { border = "rounded" },
    checker = { enabled = true, notify = false },
})

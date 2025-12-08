local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- 1. Load LazyVim Core
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },

    -- 2. Import Extras (MUST come before your custom plugins)
    
    -- Coding & Snippets
    { import = "lazyvim.plugins.extras.coding.yanky" },
    { import = "lazyvim.plugins.extras.coding.mini-surround" }, -- New
    { import = "lazyvim.plugins.extras.coding.mini-snippets" }, -- New
    { import = "lazyvim.plugins.extras.coding.luasnip" },      -- New (Standard snippet engine)
    
    -- Editor Enhancements
    { import = "lazyvim.plugins.extras.editor.mini-move" },
    { import = "lazyvim.plugins.extras.editor.refactoring" },
    { import = "lazyvim.plugins.extras.editor.illuminate" },    -- New (Highlights word under cursor)

    -- Languages
    { import = "lazyvim.plugins.extras.lang.go" },
    { import = "lazyvim.plugins.extras.lang.python" },
    { import = "lazyvim.plugins.extras.lang.clangd" },

    -- UI & Animation
    { import = "lazyvim.plugins.extras.ui.mini-animate" },
    { import = "lazyvim.plugins.extras.ui.smear-cursor" },

    -- Utilities
    { import = "lazyvim.plugins.extras.util.chezmoi" },
    { import = "lazyvim.plugins.extras.util.rest" },

    -- LSP & Formatting
    { import = "lazyvim.plugins.extras.lsp.neoconf" },
    { import = "lazyvim.plugins.extras.formatting.black" },

    -- 3. Import your custom plugins (defined in lua/plugins/*.lua)
    { import = "plugins" },
  },
  defaults = {
    lazy = false,
    version = false, 
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = { enabled = true }, 
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
})

return {
  -----------------------------------------------------------------------------
  -- 1. MASON: Ensure Tools are Installed
  -- Defines tools that don't have automatic Extras (like Bash or Lua setup).
  -----------------------------------------------------------------------------
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- Lua (Fixes exit code 127)
        "lua-language-server",
        "stylua",

        -- Bash / Shell
        "bash-language-server",
        "shellcheck",
        "shfmt",

        -- C/C++ (Optional)
        "clang-format",
      },
    },
  },

  -----------------------------------------------------------------------------
  -- 2. TREESITTER: Syntax Highlighting
  -----------------------------------------------------------------------------
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

  -----------------------------------------------------------------------------
  -- 3. RECIPE: Clangd Offset Encoding
  -----------------------------------------------------------------------------
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

  -----------------------------------------------------------------------------
  -- 4. CONFIG: Refactoring.nvim
  -----------------------------------------------------------------------------
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

  -----------------------------------------------------------------------------
  -- 5. EXTRA CONFIG: Smear Cursor
  -----------------------------------------------------------------------------
  {
    "sphamba/smear-cursor.nvim",
    opts = {
      cursor_color = "none",
      hide_target_hack = true,
    },
  },
}

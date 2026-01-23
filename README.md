# Neovim Configuration (LazyVim)

This is a customized [LazyVim](https://www.lazyvim.org/) configuration.

## Prerequisites

### 1. Nerd Font (Required for Icons)

This configuration relies on **Nerd Fonts** (v3.0 or greater) for various UI icons.

- **Automated Installation**: Run the provided script to install your preferred font:
  ```bash
  ./install_fonts.sh EnvyCodeR
  ```
- **Manual Download**: [Nerd Fonts Website](https://www.nerdfonts.com/font-downloads)
- **Setup**: After installation, you **must** configure your terminal emulator to use the installed font (e.g., `EnvyCodeR Nerd Font`).

### 2. Tools (via Mason)

The configuration automatically ensures the following are installed via Mason:
- **LSP**: `lua-language-server`, `bash-language-server`, `go-language-server`, `pyright`, `clangd`.
- **Formatters/Linters**: `stylua`, `shellcheck`, `shfmt`, `black`, `clang-format`.

## Structure

- `init.lua`: Main entry point.
- `lua/config/lazy.lua`: Lazy.nvim bootstrap and LazyVim extras.
- `lua/plugins/project.lua`: Custom plugin configurations and tool enforcement.

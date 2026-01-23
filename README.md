# Neovim Configuration (LazyVim)

This is a customized [LazyVim](https://www.lazyvim.org/) configuration.

## Prerequisites

### 1. Nerd Font (Required for Icons)

This configuration relies on **Nerd Fonts** (v3.0 or greater) for various UI icons. If you do not have a Nerd Font installed, icons will appear as boxes or question marks.

- **Download**: [Nerd Fonts Website](https://www.nerdfonts.com/font-downloads)
- **Recommended**: *JetBrains Mono Nerd Font* or *Fira Code Nerd Font*.
- **Setup**: After installing the font on your system, you **must** configure your terminal emulator (Alacritty, Kitty, iTerm2, Windows Terminal, etc.) to use the installed Nerd Font.

### 2. Tools (via Mason)

The configuration automatically ensures the following are installed via Mason:
- **LSP**: `lua-language-server`, `bash-language-server`, `go-language-server`, `pyright`, `clangd`.
- **Formatters/Linters**: `stylua`, `shellcheck`, `shfmt`, `black`, `clang-format`.

## Structure

- `init.lua`: Main entry point.
- `lua/config/lazy.lua`: Lazy.nvim bootstrap and LazyVim extras.
- `lua/plugins/project.lua`: Custom plugin configurations and tool enforcement.

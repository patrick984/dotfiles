# DotFiles

Portable, low-dependency dotfiles for macOS, Linux, SSH sessions, and minimal
development containers.

## Goals

1. Deploy easily by copy or `scp`.
2. Support macOS and Linux.
3. Work well in SSH sessions and lightweight development containers.
4. Support Bash, Zsh, tmux, Vim, and Neovim when available on the host.
5. Prioritise readable light-background themes in all utilities.
6. Avoid hard failures when optional tools or plugins are missing.

## Supported Versions

- Vim 9+ with `+eval` support for the full config; `vim.tiny` starts without
  loading the full Vim configuration
- Neovim 0.12+
- tmux 3.2+
- Bash 4+ where possible
- Zsh 5+

## Installation

Run the copy-only installer from this repository:

```sh
./install.sh
```

The installer copies files into `$HOME`, creates parent directories, and backs up
existing destination files with a timestamped `.bak.YYYYMMDD-HHMMSS` suffix. It
does not create symlinks.

## Optional Tools

The configs auto-use these tools when installed and fall back gracefully when
they are unavailable:

- `git`
- `rg`
- `fzf`
- `bat` or `batcat`
- `fd` or `fdfind`
- `direnv`
- `zoxide`
- `nvim`
- `bash-completion`

## Language Servers

Neovim uses built-in LSP and only enables servers whose executables are present.
Install the relevant server for each language you use:

- C/C++: `clangd`
- Python: `pyright-langserver`
- C#: `roslyn-language-server`
- Go: `gopls`
- Rust: `rust-analyzer`
- TypeScript/JavaScript: `vtsls`
- HTML/CSS/JSON: `vscode-html-language-server`, `vscode-css-language-server`,
  `vscode-json-language-server`
- Odin: `ols`

Format-on-save is opt-in per language in `.config/nvim/init.lua`. Manual
formatting remains available through `<leader>cf` when an attached LSP supports
formatting.

## Tool-Specific Notes

### Neovim

1. Single-file config: `.config/nvim/init.lua`.
2. Uses built-in LSP support instead of requiring third-party plugins.
3. Provides language support for C, C++, Python, C#, Go, Rust,
   TypeScript/JavaScript, HTML/CSS, JSON, and Odin when the corresponding
   language servers are installed.
4. Optional plugin commands must be guarded so missing plugins do not break
   startup.

### Vim

1. Uses the same light colour theme as Neovim.
2. Keeps keybinds close to Neovim where practical.
3. ALE, FZF, ripgrep, and Fugitive support are optional and guarded.
4. Native file browsing, grep, quickfix, tags, buffers, and terminal commands
   remain available without plugins.

### tmux

1. Uses a light-background status line.
2. Keeps `C-a` as the prefix.
3. Optimised for SSH with no plugin-manager dependency.

### Zsh

1. Primary interactive shell.
2. Provides a lightweight oh-my-zsh-like baseline without requiring
   oh-my-zsh.
3. Includes history, completion, prompt, git branch display, directory
   navigation helpers, and optional tool integration.

### Bash

1. Secondary shell with shared aliases, exports, PATH handling, and editor
   defaults from `.shell_common`.
2. Keeps Bash-specific prompt and completion setup small.

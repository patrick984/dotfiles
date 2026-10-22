# DotFiles

Portable, low-dependency dotfiles for macOS, Linux, SSH sessions, and minimal
development containers.

## Goals

1. Deploy easily by copy or `scp`.
2. Support macOS and Linux.
3. Work well in SSH sessions and lightweight development containers.
4. Support Bash, Zsh, tmux, Vim, Neovim, and Helix when available on the host.
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

Preview or remove backups previously created by the installer:

```sh
./cleanup-backups.sh --dry-run
./cleanup-backups.sh
```

Use `./cleanup-backups.sh --yes` for non-interactive cleanup.

## Optional Tools

The configs auto-use these tools when installed and fall back gracefully when
they are unavailable:

- `git`
- `delta` (usually packaged as `git-delta`)
- `rg`
- `fzf`
- `bat` or `batcat`
- `fd` or `fdfind`
- `direnv`
- `zoxide`
- `nvim`
- `hx`
- `bash-completion`

When `delta` is installed, Git uses it for syntax-highlighted diffs with line
numbers and `n`/`N` navigation. The configuration is light-background oriented
and also enables `zdiff3` merge-conflict markers. Install it with your package
manager (the package is usually named `git-delta`) or with Cargo:

```sh
cargo install git-delta --locked
```

Run `./install.sh` after installing it. Delta is an optional executable, but the
managed Git config expects it to be present once installed.

For structural Python highlighting, install `nvim-treesitter` and its Python
parser with:

```sh
./setup-neovim-treesitter.sh
```

The setup requires Git, Cargo (when `tree-sitter-cli` is not already installed),
a C compiler, and network access. The normal `install.sh` remains copy-only.

Install or update all optional Neovim plugins without a plugin manager:

```sh
./setup-neovim-plugins.sh
```

Plugins are cloned into `~/.config/nvim/pack/plugins/opt`. Rerunning the script
updates each checkout with a fast-forward-only pull. `blink.cmp` stays on its
stable `v1` branch; the remaining plugins track their default branches. The
normal `install.sh` remains copy-only and never downloads plugins.

Install or update Helix from its latest official binary release:

```sh
./setup-helix.sh
```

The script detects ARM64 or x86-64 Linux/macOS, downloads the matching release,
and installs versioned files beneath `~/.local/share/helix-binary`. It links
`~/.local/bin/hx` and `~/.config/helix/runtime` to the selected release so the
binary, grammars, and queries stay in sync. Rerunning it updates to the latest
release without compiling anything. Set `HELIX_VERSION`, `HELIX_INSTALL_DIR`,
or `HELIX_BIN_DIR` to override the defaults. Curl, tar, and xz are required. The
normal `install.sh` remains copy-only and does not download Helix.

## Language Servers

Neovim uses built-in LSP and only enables servers whose executables are present.
Install the relevant server for each language you use:

- C/C++: `clangd`
- Python types, navigation, completion, and inlay hints:
  `basedpyright-langserver`
- Python linting, formatting, import organization, and fixes: `ruff`
- C#: `roslyn-language-server`
- Go: `gopls`
- Rust: `rust-analyzer`
- TypeScript/JavaScript: `vtsls`
- HTML/CSS/JSON: `vscode-html-language-server`, `vscode-css-language-server`,
  `vscode-json-language-server`
- Odin: `ols`

For the Python tools, one portable installation option is:

```sh
uv tool install basedpyright
uv tool install ruff
```

BasedPyright starts in `standard` type-checking mode. Override that per project
in `pyproject.toml` or `pyrightconfig.json` when a codebase is ready for stricter
checking. Ruff formats Python on save; use `<leader>ca` for available code actions.

Format-on-save is opt-in per language in `.config/nvim/init.lua`. Manual
formatting remains available through `<leader>cf` when an attached LSP supports
formatting.

Helix uses the same server executables and enables inlay hints globally. C# is
formatted on save with `csharpier`; other languages keep formatting manual via
`<space>cf`.

## Tool-Specific Notes

### Helix

1. Uses a light theme, soft wrapping, four-space indentation, and a compact
   status line similar to the Neovim configuration.
2. LSP features are available through Helix defaults (`gd`, `gD`, `gr`, `gi`,
   `<space>k`) and Neovim-like additions (`<space>rn`, `<space>ca`,
   `<space>cd`, `<space>cs`, and `<space>cf`).
3. Use `<space>th` to toggle inlay hints, `<C-p>` or `<space>ff` to find files,
   `<space>fg` to search the project, and `<space>fb` to select a buffer.
4. Run `hx --health <language>` to check grammar and language-server discovery.

### Neovim

1. Native Lua config rooted at `.config/nvim/init.lua`.
2. Uses built-in LSP support, with optional `blink.cmp` completion when the
   plugin is installed.
3. Provides language support for C, C++, Python, C#, Go, Rust,
   TypeScript/JavaScript, HTML/CSS, JSON, and Odin when the corresponding
   language servers are installed.
4. Optional plugin commands must be guarded so missing plugins do not break
   startup.
5. `grug-far.nvim` is supported when installed as
   `~/.config/nvim/pack/plugins/opt/grug-far.nvim` alongside `rg`; use
   `<leader>sr` for project search and replace.

### Vim

1. Uses the same light colour theme as Neovim.
2. Keeps keybinds close to Neovim where practical.
3. ALE, FZF, ripgrep, and Fugitive support are optional and guarded.
4. Native file browsing, grep, quickfix, tags, buffers, and terminal commands
   remain available without plugins.

### tmux

1. Uses a light-background status line.
2. Uses `C-Space` as the prefix.
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

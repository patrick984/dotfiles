#!/usr/bin/env bash
set -euo pipefail

plugin_dir="$HOME/.config/nvim/pack/plugins/opt/nvim-treesitter"
cargo_bin_dir="${CARGO_HOME:-$HOME/.cargo}/bin"

if ! command -v git >/dev/null 2>&1; then
    printf 'git is required to install nvim-treesitter\n' >&2
    exit 1
fi

if ! command -v cc >/dev/null 2>&1; then
    printf 'a C compiler is required to build the Python parser\n' >&2
    exit 1
fi

if ! command -v tree-sitter >/dev/null 2>&1; then
    if ! command -v cargo >/dev/null 2>&1; then
        printf 'tree-sitter-cli 0.26.1+ is required; install it and rerun this script\n' >&2
        exit 1
    fi

    printf 'install tree-sitter-cli with Cargo\n'
    cargo install tree-sitter-cli --version 0.27.0 --locked
    export PATH="$cargo_bin_dir:$PATH"
fi

if [[ ! -d "$plugin_dir/.git" ]]; then
    mkdir -p "$(dirname "$plugin_dir")"
    git clone --filter=blob:none https://github.com/nvim-treesitter/nvim-treesitter.git "$plugin_dir"
else
    printf 'use existing %s\n' "$plugin_dir"
fi

printf 'install Python parser and highlight queries\n'
nvim --headless -u NONE \
    "+set packpath^=$HOME/.config/nvim" \
    "+packadd nvim-treesitter" \
    "+lua require('nvim-treesitter').install({'python'}):wait(300000)" \
    "+qa"

printf 'Python Treesitter highlighting installed\n'

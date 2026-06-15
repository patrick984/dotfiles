#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
stamp="$(date +%Y%m%d-%H%M%S)"

copy_file() {
    local src="$1"
    local dst="$2"
    local src_path="$repo_dir/$src"
    local dst_path="$HOME/$dst"

    if [[ ! -f "$src_path" ]]; then
        printf 'skip missing %s\n' "$src" >&2
        return
    fi

    mkdir -p "$(dirname "$dst_path")"

    if [[ -e "$dst_path" && ! -L "$dst_path" ]]; then
        cp -p "$dst_path" "$dst_path.bak.$stamp"
        printf 'backup %s -> %s\n' "$dst_path" "$dst_path.bak.$stamp"
    elif [[ -L "$dst_path" ]]; then
        cp -P "$dst_path" "$dst_path.bak.$stamp"
        printf 'backup symlink %s -> %s\n' "$dst_path" "$dst_path.bak.$stamp"
        rm -f -- "$dst_path"
    fi

    cp "$src_path" "$dst_path"
    printf 'install %s -> %s\n' "$src" "$dst_path"
}

copy_file ".shell_common" ".shell_common"
copy_file ".bashrc" ".bashrc"
copy_file ".zshrc" ".zshrc"
copy_file ".tmux.conf" ".tmux.conf"
copy_file ".vimrc" ".vimrc"
copy_file ".vim/colors/light_custom.vim" ".vim/colors/light_custom.vim"
copy_file ".config/nvim/init.lua" ".config/nvim/init.lua"

printf 'done\n'

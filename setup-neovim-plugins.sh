#!/usr/bin/env bash
set -euo pipefail

plugin_root="${XDG_CONFIG_HOME:-$HOME/.config}/nvim/pack/plugins/opt"

if ! command -v git >/dev/null 2>&1; then
    printf 'git is required to install Neovim plugins\n' >&2
    exit 1
fi

mkdir -p "$plugin_root"

install_plugin() {
    local name="$1"
    local url="$2"
    local branch="${3:-}"
    local destination="$plugin_root/$name"

    if [[ -e "$destination" && ! -d "$destination/.git" ]]; then
        printf 'cannot update %s: %s exists but is not a Git checkout\n' \
            "$name" "$destination" >&2
        return 1
    fi

    if [[ -d "$destination/.git" ]]; then
        printf 'update %s\n' "$name"
        git -C "$destination" pull --ff-only
        return
    fi

    printf 'install %s\n' "$name"
    if [[ -n "$branch" ]]; then
        git clone --filter=blob:none --branch "$branch" --single-branch \
            "$url" "$destination"
    else
        git clone --filter=blob:none "$url" "$destination"
    fi
}

# Keep blink.cmp on its stable v1 branch. The other plugins track their default
# branches and are updated with fast-forward-only pulls on subsequent runs.
install_plugin "blink.cmp" \
    "https://github.com/Saghen/blink.cmp.git" "v1"
install_plugin "friendly-snippets" \
    "https://github.com/rafamadriz/friendly-snippets.git"
install_plugin "fzf-lua" \
    "https://github.com/ibhagwan/fzf-lua.git"
install_plugin "nvim-web-devicons" \
    "https://github.com/nvim-tree/nvim-web-devicons.git"
install_plugin "vim-fugitive" \
    "https://github.com/tpope/vim-fugitive.git"
install_plugin "diffs.nvim" \
    "https://github.com/barrettruth/diffs.nvim.git"
install_plugin "grug-far.nvim" \
    "https://github.com/MagicDuck/grug-far.nvim.git"
install_plugin "nvim-treesitter" \
    "https://github.com/nvim-treesitter/nvim-treesitter.git"

printf 'Neovim plugins installed in %s\n' "$plugin_root"
printf 'Run ./setup-neovim-treesitter.sh to install the Python parser.\n'

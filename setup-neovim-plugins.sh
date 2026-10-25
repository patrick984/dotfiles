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
    local destination="$plugin_root/$name"

    if [[ -e "$destination" && ! -d "$destination/.git" ]]; then
        printf 'cannot update %s: %s exists but is not a Git checkout\n' \
            "$name" "$destination" >&2
        return 1
    fi

    if [[ -d "$destination/.git" ]]; then
        printf 'update %s\n' "$name"
        git -C "$destination" remote set-url origin "$url"
        git -C "$destination" pull --ff-only
        return
    fi

    printf 'install %s\n' "$name"
    git clone --filter=blob:none "$url" "$destination"
}

install_tagged_plugin() {
    local name="$1"
    local url="$2"
    local tag_pattern="$3"
    local tag_regex="$4"
    local destination="$plugin_root/$name"
    local candidate_tag
    local latest_tag

    if [[ -e "$destination" && ! -d "$destination/.git" ]]; then
        printf 'cannot update %s: %s exists but is not a Git checkout\n' \
            "$name" "$destination" >&2
        return 1
    fi

    if [[ -d "$destination/.git" ]]; then
        printf 'update %s release tags\n' "$name"
        git -C "$destination" remote set-url origin "$url"
    else
        printf 'install %s from a release tag\n' "$name"
        git clone --filter=blob:none --no-checkout "$url" "$destination"
    fi

    git -C "$destination" fetch --force --tags origin
    while IFS= read -r candidate_tag; do
        if [[ "$candidate_tag" =~ $tag_regex ]]; then
            latest_tag="$candidate_tag"
            break
        fi
    done < <(git -C "$destination" tag --list "$tag_pattern" \
        --sort=-version:refname)
    if [[ -z "$latest_tag" ]]; then
        printf 'no %s release tag matching %s was found\n' \
            "$name" "$tag_pattern" >&2
        return 1
    fi

    git -C "$destination" checkout --detach "$latest_tag"
    printf '%s selected release %s\n' "$name" "$latest_tag"
}

# Blink only downloads its prebuilt fuzzy matcher from an exact release tag.
# The other plugins track their default branches with fast-forward-only pulls.
install_tagged_plugin "blink.cmp" \
    "https://github.com/Saghen/blink.cmp.git" "v1.*" '^v1\.[0-9]+\.[0-9]+$'
install_plugin "friendly-snippets" \
    "https://github.com/rafamadriz/friendly-snippets.git"
install_plugin "fzf-lua" \
    "https://github.com/ibhagwan/fzf-lua.git"
install_plugin "nvim-web-devicons" \
    "https://github.com/nvim-tree/nvim-web-devicons.git"
install_plugin "vim-fugitive" \
    "https://github.com/tpope/vim-fugitive.git"
install_plugin "diffs.nvim" \
    "https://forge.barrettruth.com/barrettruth/diffs.nvim.git"
install_plugin "grug-far.nvim" \
    "https://github.com/MagicDuck/grug-far.nvim.git"
install_plugin "nvim-treesitter" \
    "https://github.com/nvim-treesitter/nvim-treesitter.git"

printf 'Neovim plugins installed in %s\n' "$plugin_root"
printf 'Run ./setup-neovim-treesitter.sh to install the Python parser.\n'

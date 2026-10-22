#!/usr/bin/env bash
set -euo pipefail

github_repo="neovim/neovim"
requested_version="${NEOVIM_VERSION:-latest}"
install_root="${NEOVIM_INSTALL_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/neovim-binary}"
bin_dir="${NEOVIM_BIN_DIR:-$HOME/.local/bin}"
current_link="$install_root/current"

usage() {
    printf 'Usage: %s\n' "${0##*/}"
    printf 'Install or update Neovim from an official pre-built release.\n'
    printf 'Overrides: NEOVIM_VERSION, NEOVIM_INSTALL_DIR, NEOVIM_BIN_DIR\n'
}

if [[ ${1:-} == "--help" || ${1:-} == "-h" ]]; then
    usage
    exit 0
elif [[ $# -gt 0 ]]; then
    printf 'unknown option: %s\n' "$1" >&2
    usage >&2
    exit 2
fi

for command_name in curl tar; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        printf '%s is required to install Neovim\n' "$command_name" >&2
        exit 1
    fi
done

case "$(uname -s)" in
    Linux) platform="linux" ;;
    Darwin) platform="macos" ;;
    *)
        printf 'unsupported operating system: %s\n' "$(uname -s)" >&2
        exit 1
        ;;
esac

case "$(uname -m)" in
    aarch64|arm64) architecture="arm64" ;;
    x86_64|amd64) architecture="x86_64" ;;
    *)
        printf 'unsupported architecture: %s\n' "$(uname -m)" >&2
        printf 'Official Neovim releases provide binaries for arm64 and x86_64.\n' >&2
        exit 1
        ;;
esac

if [[ -e "$current_link" && ! -L "$current_link" ]]; then
    printf 'cannot select a Neovim release: %s exists and is not a symlink\n' \
        "$current_link" >&2
    exit 1
fi

if [[ "$requested_version" == "latest" ]]; then
    printf 'find latest stable Neovim release\n'
    release_json="$(curl --fail --location --silent --show-error \
        "https://api.github.com/repos/$github_repo/releases/latest")"
    version="$(sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' \
        <<<"$release_json" | head -n 1)"
    if [[ -z "$version" ]]; then
        printf 'could not determine the latest Neovim release\n' >&2
        exit 1
    fi
else
    version="v${requested_version#v}"
fi

version_number="${version#v}"
archive_name="nvim-$platform-$architecture.tar.gz"
download_url="https://github.com/$github_repo/releases/download/$version/$archive_name"
release_dir="$install_root/releases/$version_number-$architecture-$platform"

if [[ ! -x "$release_dir/bin/nvim" || ! -d "$release_dir/share/nvim/runtime" ]]; then
    temporary_dir="$(mktemp -d "${TMPDIR:-/tmp}/neovim-install.XXXXXX")"
    trap 'rm -rf -- "$temporary_dir"' EXIT
    archive_path="$temporary_dir/$archive_name"
    extracted_dir="$temporary_dir/extracted"

    printf 'download Neovim %s for %s-%s\n' "$version_number" "$architecture" "$platform"
    curl --fail --location --show-error --progress-bar \
        --output "$archive_path" "$download_url"

    if [[ "$platform" == "macos" ]] && command -v xattr >/dev/null 2>&1; then
        xattr -c "$archive_path"
    fi

    mkdir -p "$extracted_dir"
    tar -xzf "$archive_path" --strip-components=1 -C "$extracted_dir"
    if [[ ! -x "$extracted_dir/bin/nvim" \
        || ! -d "$extracted_dir/share/nvim/runtime" ]]; then
        printf 'downloaded archive does not contain the Neovim binary and runtime\n' >&2
        exit 1
    fi

    installed_version="$("$extracted_dir/bin/nvim" --version | head -n 1)"
    if [[ "$installed_version" != "NVIM v$version_number" ]]; then
        printf 'downloaded binary reported an unexpected version: %s\n' \
            "$installed_version" >&2
        exit 1
    fi

    mkdir -p "$install_root/releases"
    if [[ -e "$release_dir" ]]; then
        printf 'cannot install: incomplete release directory exists at %s\n' \
            "$release_dir" >&2
        exit 1
    fi
    mv "$extracted_dir" "$release_dir"
else
    printf 'Neovim %s is already downloaded\n' "$version_number"
fi

mkdir -p "$install_root" "$bin_dir"
ln -sfn "$release_dir" "$current_link"

if [[ -e "$bin_dir/nvim" && ! -L "$bin_dir/nvim" ]]; then
    binary_backup="$bin_dir/nvim.bak.$(date +%Y%m%d-%H%M%S)"
    mv "$bin_dir/nvim" "$binary_backup"
    printf 'backup existing nvim -> %s\n' "$binary_backup"
fi
ln -sfn "$current_link/bin/nvim" "$bin_dir/nvim"

printf 'Neovim %s installed: %s\n' "$version_number" "$bin_dir/nvim"
printf 'Release selected: %s -> %s\n' "$current_link" "$release_dir"
printf 'Run hash -r, then nvim --version and nvim +checkhealth.\n'

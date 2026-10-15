#!/usr/bin/env bash
set -euo pipefail

github_repo="helix-editor/helix"
requested_version="${HELIX_VERSION:-latest}"
install_root="${HELIX_INSTALL_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/helix-binary}"
bin_dir="${HELIX_BIN_DIR:-$HOME/.local/bin}"
config_root="${XDG_CONFIG_HOME:-$HOME/.config}/helix"
current_link="$install_root/current"
runtime_link="$config_root/runtime"

usage() {
    printf 'Usage: %s\n' "${0##*/}"
    printf 'Install or update Helix from an official pre-built release.\n'
    printf 'Overrides: HELIX_VERSION, HELIX_INSTALL_DIR, HELIX_BIN_DIR\n'
}

if [[ ${1:-} == "--help" || ${1:-} == "-h" ]]; then
    usage
    exit 0
elif [[ $# -gt 0 ]]; then
    printf 'unknown option: %s\n' "$1" >&2
    usage >&2
    exit 2
fi

for command_name in curl tar xz; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        printf '%s is required to install Helix\n' "$command_name" >&2
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
    aarch64|arm64) architecture="aarch64" ;;
    x86_64|amd64) architecture="x86_64" ;;
    *)
        printf 'unsupported architecture: %s\n' "$(uname -m)" >&2
        printf 'Official Helix releases provide Linux binaries for aarch64 and x86_64.\n' >&2
        exit 1
        ;;
esac

if [[ -e "$current_link" && ! -L "$current_link" ]]; then
    printf 'cannot select a Helix release: %s exists and is not a symlink\n' \
        "$current_link" >&2
    exit 1
fi
if [[ -e "$runtime_link" && ! -L "$runtime_link" ]]; then
    printf 'cannot link Helix runtime: %s exists and is not a symlink\n' \
        "$runtime_link" >&2
    printf 'move it aside, then rerun this script\n' >&2
    exit 1
fi

if [[ "$requested_version" == "latest" ]]; then
    printf 'find latest Helix release\n'
    release_json="$(curl --fail --location --silent --show-error \
        "https://api.github.com/repos/$github_repo/releases/latest")"
    version="$(sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' \
        <<<"$release_json" | head -n 1)"
    if [[ -z "$version" ]]; then
        printf 'could not determine the latest Helix release\n' >&2
        exit 1
    fi
else
    version="${requested_version#v}"
fi

archive_name="helix-$version-$architecture-$platform.tar.xz"
download_url="https://github.com/$github_repo/releases/download/$version/$archive_name"
release_dir="$install_root/releases/$version-$architecture-$platform"

if [[ ! -x "$release_dir/hx" || ! -d "$release_dir/runtime" ]]; then
    temporary_dir="$(mktemp -d "${TMPDIR:-/tmp}/helix-install.XXXXXX")"
    trap 'rm -rf -- "$temporary_dir"' EXIT
    archive_path="$temporary_dir/$archive_name"
    extracted_dir="$temporary_dir/extracted"

    printf 'download Helix %s for %s-%s\n' "$version" "$architecture" "$platform"
    curl --fail --location --show-error --progress-bar \
        --output "$archive_path" "$download_url"

    mkdir -p "$extracted_dir"
    tar -xJf "$archive_path" --strip-components=1 -C "$extracted_dir"
    if [[ ! -x "$extracted_dir/hx" || ! -d "$extracted_dir/runtime" ]]; then
        printf 'downloaded archive does not contain hx and runtime\n' >&2
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
    printf 'Helix %s is already downloaded\n' "$version"
fi

mkdir -p "$install_root" "$bin_dir" "$config_root"
ln -sfn "$release_dir" "$current_link"

if [[ -e "$bin_dir/hx" && ! -L "$bin_dir/hx" ]]; then
    binary_backup="$bin_dir/hx.bak.$(date +%Y%m%d-%H%M%S)"
    mv "$bin_dir/hx" "$binary_backup"
    printf 'backup existing hx -> %s\n' "$binary_backup"
fi
ln -sfn "$current_link/hx" "$bin_dir/hx"

ln -sfn "$current_link/runtime" "$runtime_link"

printf 'Helix %s installed: %s\n' "$version" "$bin_dir/hx"
printf 'Runtime linked: %s -> %s\n' "$runtime_link" "$current_link/runtime"
printf 'Run hash -r, then hx --version and hx --health.\n'

#!/usr/bin/env bash
set -euo pipefail

helix_url="https://github.com/helix-editor/helix.git"
helix_branch="${HELIX_BRANCH:-master}"
source_dir="${HELIX_SOURCE_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/helix}"
install_root="${HELIX_INSTALL_ROOT:-$HOME/.local}"
config_root="${XDG_CONFIG_HOME:-$HOME/.config}/helix"
runtime_link="$config_root/runtime"

if [[ ${1:-} == "--help" || ${1:-} == "-h" ]]; then
    printf 'Usage: %s\n' "${0##*/}"
    printf 'Install or update Helix from source in the current user account.\n'
    printf 'Overrides: HELIX_BRANCH, HELIX_SOURCE_DIR, HELIX_INSTALL_ROOT\n'
    exit 0
elif [[ $# -gt 0 ]]; then
    printf 'unknown option: %s\n' "$1" >&2
    exit 2
fi

for command_name in git cargo; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        printf '%s is required to install Helix\n' "$command_name" >&2
        exit 1
    fi
done

if [[ -e "$source_dir" && ! -d "$source_dir/.git" ]]; then
    printf 'cannot install Helix: %s exists but is not a Git checkout\n' \
        "$source_dir" >&2
    exit 1
fi

if [[ -d "$source_dir/.git" ]]; then
    current_branch="$(git -C "$source_dir" branch --show-current)"
    if [[ "$current_branch" != "$helix_branch" ]]; then
        printf 'cannot update Helix: %s is on branch %s, expected %s\n' \
            "$source_dir" "${current_branch:-detached HEAD}" "$helix_branch" >&2
        exit 1
    fi
    if ! git -C "$source_dir" diff --quiet \
        || ! git -C "$source_dir" diff --cached --quiet; then
        printf 'cannot update Helix: %s has uncommitted changes\n' "$source_dir" >&2
        exit 1
    fi

    printf 'update Helix (%s)\n' "$helix_branch"
    git -C "$source_dir" remote set-url origin "$helix_url"
    git -C "$source_dir" pull --ff-only origin "$helix_branch"
else
    printf 'clone Helix (%s)\n' "$helix_branch"
    mkdir -p "$(dirname "$source_dir")"
    git clone --filter=blob:none --branch "$helix_branch" --single-branch \
        "$helix_url" "$source_dir"
fi

printf 'build and install Helix in %s\n' "$install_root"
cargo install --path "$source_dir/helix-term" --locked --root "$install_root"

mkdir -p "$config_root"
if [[ -e "$runtime_link" && ! -L "$runtime_link" ]]; then
    printf 'cannot link Helix runtime: %s exists and is not a symlink\n' \
        "$runtime_link" >&2
    printf 'move it aside, then rerun this script\n' >&2
    exit 1
fi
ln -sfn "$source_dir/runtime" "$runtime_link"

printf 'Helix installed: %s\n' "$install_root/bin/hx"
printf 'Runtime linked: %s -> %s\n' "$runtime_link" "$source_dir/runtime"
printf 'Ensure %s/bin appears before /usr/bin in PATH, then run hx --health.\n' \
    "$install_root"

#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dry_run=0
assume_yes=0

usage() {
    printf 'Usage: %s [--dry-run] [--yes]\n' "${0##*/}"
    printf 'Remove timestamped backups created by install.sh.\n'
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            dry_run=1
            ;;
        --yes|-y)
            assume_yes=1
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            printf 'unknown option: %s\n' "$1" >&2
            usage >&2
            exit 2
            ;;
    esac
    shift
done

managed_paths=(
    ".shell_common"
    ".bashrc"
    ".zshrc"
    ".tmux.conf"
    ".vimrc"
    ".vim/colors/light_custom.vim"
)

while IFS= read -r -d '' source_path; do
    relative_path="${source_path#"$repo_dir/"}"
    managed_paths+=("$relative_path")
done < <(find "$repo_dir/.config/nvim" -type f -print0)

backups=()
shopt -s nullglob
for relative_path in "${managed_paths[@]}"; do
    destination="$HOME/$relative_path"
    for candidate in "$destination".bak.*; do
        suffix="${candidate#"$destination.bak."}"
        if [[ "$suffix" =~ ^[0-9]{8}-[0-9]{6}$ ]] && [[ -f "$candidate" || -L "$candidate" ]]; then
            backups+=("$candidate")
        fi
    done
done
shopt -u nullglob

if [[ ${#backups[@]} -eq 0 ]]; then
    printf 'no installer backups found\n'
    exit 0
fi

printf 'found %d installer backup(s):\n' "${#backups[@]}"
printf '  %s\n' "${backups[@]}"

if [[ $dry_run -eq 1 ]]; then
    printf 'dry run; nothing removed\n'
    exit 0
fi

if [[ $assume_yes -ne 1 ]]; then
    if [[ ! -t 0 ]]; then
        printf 'refusing to remove backups without a terminal; pass --yes\n' >&2
        exit 1
    fi
    read -r -p 'Remove these backups? [y/N] ' reply
    case "$reply" in
        y|Y|yes|YES) ;;
        *)
            printf 'cancelled\n'
            exit 0
            ;;
    esac
fi

for backup in "${backups[@]}"; do
    rm -f -- "$backup"
    printf 'removed %s\n' "$backup"
done

printf 'done\n'

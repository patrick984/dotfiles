#!/usr/bin/env bash
set -euo pipefail

github_repo="neovim/neovim"
requested_version="${NEOVIM_VERSION:-latest}"
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
output_dir="${NEOVIM_DEB_OUTPUT_DIR:-$repo_dir/dist}"
maintainer="${NEOVIM_DEB_MAINTAINER:-Local package builder <root@localhost>}"
package_name="neovim-upstream"

usage() {
    printf 'Usage: %s\n' "${0##*/}"
    printf 'Build a Debian package from an official Neovim Linux release.\n'
    printf 'Overrides: NEOVIM_VERSION, NEOVIM_DEB_OUTPUT_DIR, NEOVIM_DEB_MAINTAINER\n'
}

if [[ ${1:-} == "--help" || ${1:-} == "-h" ]]; then
    usage
    exit 0
elif [[ $# -gt 0 ]]; then
    printf 'unknown option: %s\n' "$1" >&2
    usage >&2
    exit 2
fi

if [[ "$(uname -s)" != "Linux" ]]; then
    printf 'Debian packages can only be built by this script on Linux\n' >&2
    exit 1
fi

for command_name in curl dpkg-deb tar; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        printf '%s is required to build the Neovim package\n' "$command_name" >&2
        exit 1
    fi
done

case "$(uname -m)" in
    aarch64|arm64)
        release_architecture="arm64"
        debian_architecture="arm64"
        ;;
    x86_64|amd64)
        release_architecture="x86_64"
        debian_architecture="amd64"
        ;;
    *)
        printf 'unsupported architecture: %s\n' "$(uname -m)" >&2
        printf 'Official Neovim Linux releases provide binaries for arm64 and x86_64.\n' >&2
        exit 1
        ;;
esac

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
if [[ ! "$version_number" =~ ^[0-9][0-9A-Za-z.+~:-]*$ ]]; then
    printf 'invalid Neovim version for a Debian package: %s\n' "$version_number" >&2
    exit 1
fi

archive_name="nvim-linux-$release_architecture.tar.gz"
download_url="https://github.com/$github_repo/releases/download/$version/$archive_name"
package_version="$version_number-1"
package_file="${package_name}_${package_version}_${debian_architecture}.deb"

temporary_dir="$(mktemp -d "${TMPDIR:-/tmp}/neovim-deb.XXXXXX")"
trap 'rm -rf -- "$temporary_dir"' EXIT
archive_path="$temporary_dir/$archive_name"
extracted_dir="$temporary_dir/extracted"
package_root="$temporary_dir/package"
install_dir="$package_root/opt/$package_name/$version_number"

printf 'download Neovim %s for Linux %s\n' "$version_number" "$release_architecture"
curl --fail --location --show-error --progress-bar \
    --output "$archive_path" "$download_url"

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

mkdir -p "$install_dir" "$package_root/usr/bin" "$package_root/DEBIAN"
cp -a "$extracted_dir/." "$install_dir/"
ln -s "/opt/$package_name/$version_number/bin/nvim" \
    "$package_root/usr/bin/nvim"

cat >"$package_root/DEBIAN/control" <<EOF
Package: $package_name
Version: $package_version
Architecture: $debian_architecture
Maintainer: $maintainer
Depends: libc6
Provides: neovim
Conflicts: neovim
Replaces: neovim
Section: editors
Priority: optional
Homepage: https://neovim.io/
Description: Neovim from the official upstream binary release
 This local package installs the official Neovim release and runtime beneath
 /opt and exposes nvim system-wide through /usr/bin/nvim.
EOF
chmod 0644 "$package_root/DEBIAN/control"
find "$package_root" -type d -exec chmod 0755 {} +

mkdir -p "$output_dir"
temporary_package="$temporary_dir/$package_file"
dpkg-deb --root-owner-group --build "$package_root" "$temporary_package"
mv "$temporary_package" "$output_dir/$package_file"

printf 'built %s\n' "$output_dir/$package_file"
printf 'Install for all users with:\n'
printf '  sudo apt install %q\n' "$output_dir/$package_file"

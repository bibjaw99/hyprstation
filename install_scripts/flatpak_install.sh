#!/bin/bash
set -euo pipefail

dir_of_this_script="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mapfile -t flatpak_packages < "$dir_of_this_script/package_lists/flatpak_pkg_list.txt"

install_flatpak_package () {
  [[ $# -eq 0 ]] && echo "⚠️  No packages to install." && return

  for package in "$@"; do
    if flatpak list --app | grep -q "$package"; then
      echo "✅ $package already installed."
    else
      echo "📦 Installing $package..."
      flatpak install -y "$package"
    fi
  done
}

install_flatpak_package "${flatpak_packages[@]}"

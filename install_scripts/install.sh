#!/usr/bin/env bash
set -euo pipefail

# Create the github clone destination
mkdir -p "$HOME/github"

# Configurable paths
REPO_URL="https://github.com/bibjaw99/workstation_testing"
GIT_DIR="$HOME/github/reponame"
DEST_DIR="$HOME/.local/share/dotfiles"

# Ensure git is installed
if ! command -v git &>/dev/null; then
  echo "❌ git is not installed. Aborting."
  exit 1
fi

echo "📥 Cloning repo from $REPO_URL to $GIT_DIR..."
git clone "$REPO_URL" "$GIT_DIR"

# Check if dotfiles subfolder exists in repo
if [[ ! -d "$GIT_DIR/dotfiles" ]]; then
  echo "❌ 'dotfiles/' directory not found in the repository."
  exit 1
fi

# Prompt before overwriting existing DEST_DIR
if [[ -d "$DEST_DIR" ]]; then
  echo "⚠️  $DEST_DIR already exists. Overwrite? [y/N]"
  read -r confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    rm -rf "$DEST_DIR"
  else
    echo "❌ Aborted."
    exit 1
  fi
fi

# Copy only the dotfiles folder (excluding .git)
echo "📦 Copying dotfiles to $DEST_DIR..."
rsync -a --exclude '.git' "$GIT_DIR/dotfiles/" "$DEST_DIR/"

echo "📁 Switching to $DEST_DIR"
cd "$DEST_DIR"

echo "📦 Running package installer..."
bash ./package_install.sh

echo "🔗 Linking config directories..."
bash ./symlink_configs.sh

echo "🔗 Linking config files..."
bash ./symlink_files.sh

echo "✅ Done!"

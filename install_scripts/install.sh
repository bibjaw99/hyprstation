#!/usr/bin/env bash
set -euo pipefail

# ───── Config ────────────────────────────────────────────────────
REPO_URL="https://github.com/bibjaw99/workstation_testing"
DEST_DIR="$HOME/.local/share/dotfiles"
GITHUB_CLONE_DIR="$HOME/github"
INSTALL_SCRIPT_DIR="$HOME/github/workstation_testing/install_scripts"

# ───── Color codes ───────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No color

# ───── Helpers ───────────────────────────────────────────────────
function print() {
  echo -e "${GREEN}✔ $1${NC}"
}

function warn() {
  echo -e "${YELLOW}⚠ $1${NC}"
}

function error() {
  echo -e "${RED}✖ $1${NC}" >&2
  exit 1
}

# ───── Ensure git is installed ───────────────────────────────────
if ! command -v git &>/dev/null; then
  error "git is not installed. Please install git and retry."
fi

# ───── Prepare directories ───────────────────────────────────────
mkdir -p "$GITHUB_CLONE_DIR"

REPO_NAME=$(basename "$REPO_URL" .git)              # Strip .git if present
GIT_DIR="$GITHUB_CLONE_DIR/$REPO_NAME"

print "Cloning repo: $REPO_URL → $GIT_DIR"
git clone --depth=1 "$REPO_URL" "$GIT_DIR"

# ───── Check if dotfiles/ exists ─────────────────────────────────
if [[ ! -d "$GIT_DIR/dotfiles" ]]; then
  error "'dotfiles/' directory not found in the repository root."
fi

# ───── Prompt before overwrite ───────────────────────────────────
if [[ -d "$DEST_DIR" ]]; then
  warn "$DEST_DIR already exists. Overwrite? [y/N]"
  read -r confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    error "Aborted by user."
  fi
  rm -rf "$DEST_DIR"
fi

# ───── Copy dotfiles/ → .local/share/dotfiles ────────────────────
print "Copying dotfiles to $DEST_DIR"
rsync -a --exclude='.git' "$GIT_DIR/dotfiles/" "$DEST_DIR/"

# ───── Run setup scripts ─────────────────────────────────────────
print "Running package_install.sh"

cd $INSTALL_SCRIPT_DIR

bash "package_install.sh"

print "Running symlink_configs.sh"
bash "symlink_configs.sh"

print "Running symlink_files.sh"
bash "symlink_files.sh"

print "Installation complete!"

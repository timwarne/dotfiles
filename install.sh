#!/usr/bin/env bash
# =============================================================================
# Dotfiles Install Script
# Symlinks dotfiles from this repo to your home directory.
# Usage: ./install.sh
# =============================================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# Files to symlink (repo file -> home target)
declare -a FILES=(
    ".zshrc"
    ".vimrc"
    ".p10k.zsh"
)

echo "==> Dotfiles installer"
echo "    Source:  $DOTFILES_DIR"
echo "    Backup:  $BACKUP_DIR"
echo ""

for file in "${FILES[@]}"; do
    target="$HOME/$file"
    source="$DOTFILES_DIR/$file"

    # Skip if source doesn't exist in repo
    if [[ ! -f "$source" ]]; then
        echo "    SKIP  $file (not in repo)"
        continue
    fi

    # Back up existing file if it's not already a symlink to our repo
    if [[ -f "$target" && ! -L "$target" ]]; then
        mkdir -p "$BACKUP_DIR"
        echo "    BACKUP  $target -> $BACKUP_DIR/$file"
        cp "$target" "$BACKUP_DIR/$file"
    fi

    # Remove existing file/symlink
    rm -f "$target"

    # Create symlink
    ln -s "$source" "$target"
    echo "    LINK  $target -> $source"
done

# Create vim undo directory
mkdir -p "$HOME/.vim/undodir"

echo ""
echo "==> Done! Restart your shell or run: source ~/.zshrc"
echo ""
echo "==> Dependencies you may need to install:"
echo "    - Oh My Zsh:                https://ohmyz.sh/#install"
echo "    - Powerlevel10k:            https://github.com/romkatv/powerlevel10k"
echo "    - zsh-autosuggestions:       https://github.com/zsh-users/zsh-autosuggestions"
echo "    - zsh-syntax-highlighting:   https://github.com/zsh-users/zsh-syntax-highlighting"

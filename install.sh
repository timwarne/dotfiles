#!/usr/bin/env bash
# =============================================================================
# Dotfiles Install Script
# Detects OS (macOS / Ubuntu), installs dependencies, and symlinks dotfiles.
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

# =============================================================================
# OS Detection
# =============================================================================
detect_os() {
    case "$(uname -s)" in
        Darwin) OS="macos" ;;
        Linux)
            if grep -qi "ubuntu\|debian" /etc/os-release 2>/dev/null; then
                OS="ubuntu"
            else
                OS="linux-other"
            fi
            ;;
        *) OS="unknown" ;;
    esac
    echo "==> Detected OS: $OS"
}

# =============================================================================
# Package Installation
# =============================================================================
install_packages() {
    echo "==> Installing system packages..."
    case "$OS" in
        macos)
            # Install Homebrew if missing
            if ! command -v brew &>/dev/null; then
                echo "    Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                # Add brew to PATH for Apple Silicon
                if [[ -f /opt/homebrew/bin/brew ]]; then
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                fi
            else
                echo "    OK  Homebrew already installed"
            fi
            # Install packages via Homebrew
            brew install git vim zsh curl gh 2>/dev/null || true
            echo "    OK  Homebrew packages installed"
            ;;
        ubuntu)
            echo "    Updating apt..."
            sudo apt-get update -qq
            sudo apt-get install -y -qq git vim zsh curl
            echo "    OK  apt packages installed"
            ;;
        *)
            echo "    WARN  Unsupported OS ($OS) — skipping package install."
            echo "    Please manually install: git, vim, zsh, curl"
            ;;
    esac
}

# =============================================================================
# Zsh as Default Shell
# =============================================================================
set_default_shell() {
    if [[ "$SHELL" != *"zsh"* ]]; then
        echo "==> Setting zsh as default shell..."
        ZSH_PATH="$(command -v zsh)"
        # Ensure zsh is in /etc/shells
        if ! grep -qF "$ZSH_PATH" /etc/shells 2>/dev/null; then
            echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
        fi
        chsh -s "$ZSH_PATH"
        echo "    OK  Default shell set to $ZSH_PATH"
    else
        echo "==> OK  zsh is already the default shell"
    fi
}

# =============================================================================
# Oh My Zsh
# =============================================================================
install_oh_my_zsh() {
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        echo "==> Installing Oh My Zsh..."
        RUNZSH=no KEEP_ZSHRC=yes \
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        echo "    OK  Oh My Zsh installed"
    else
        echo "==> OK  Oh My Zsh already installed"
    fi
}

# =============================================================================
# Zsh Plugins
# =============================================================================
install_zsh_plugins() {
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    # Powerlevel10k
    if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
        echo "==> Installing Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
            "$ZSH_CUSTOM/themes/powerlevel10k"
    else
        echo "==> OK  Powerlevel10k already installed"
    fi

    # zsh-autosuggestions
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        echo "==> Installing zsh-autosuggestions..."
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git \
            "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    else
        echo "==> OK  zsh-autosuggestions already installed"
    fi

    # zsh-syntax-highlighting
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        echo "==> Installing zsh-syntax-highlighting..."
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
            "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    else
        echo "==> OK  zsh-syntax-highlighting already installed"
    fi
}

# =============================================================================
# Symlink Dotfiles
# =============================================================================
symlink_dotfiles() {
    echo "==> Symlinking dotfiles..."
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
}

# =============================================================================
# Vim Plugins (vim-plug)
# =============================================================================
install_vim_plugins() {
    echo "==> Installing vim plugins..."
    # vim-plug auto-installs itself on first vim launch (see .vimrc),
    # but we can trigger it now for a clean setup
    if [[ ! -f "$HOME/.vim/autoload/plug.vim" ]]; then
        echo "    Installing vim-plug..."
        curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    else
        echo "    OK  vim-plug already installed"
    fi
    # Install plugins non-interactively
    vim +PlugInstall +qall 2>/dev/null
    echo "    OK  Vim plugins installed"
}

# =============================================================================
# Main
# =============================================================================
main() {
    echo ""
    echo "╔═══════════════════════════════════════╗"
    echo "║        Dotfiles Installer             ║"
    echo "╚═══════════════════════════════════════╝"
    echo ""

    detect_os
    install_packages
    set_default_shell
    install_oh_my_zsh
    install_zsh_plugins
    symlink_dotfiles
    install_vim_plugins

    echo ""
    echo "==> All done! Restart your shell or run: source ~/.zshrc"
    echo ""
}

main "$@"

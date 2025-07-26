#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Configuration
FORCE=false
BACKUP=true
VERBOSE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --force|-f)
            FORCE=true
            shift
            ;;
        --no-backup)
            BACKUP=false
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --force, -f     Force installation without prompts"
            echo "  --no-backup     Skip backing up existing configs"
            echo "  --verbose, -v   Show detailed output"
            echo "  --help, -h      Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Helper functions
log() {
    echo -e "${GREEN}==>${NC} $1"
}

error() {
    echo -e "${RED}Error:${NC} $1" >&2
}

warning() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

info() {
    echo -e "${BLUE}Info:${NC} $1"
}

confirm() {
    if [[ "$FORCE" == true ]]; then
        return 0
    fi
    
    read -p "$1 [y/N] " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin)
            echo "macos"
            ;;
        Linux)
            echo "linux"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            echo "windows"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Get Cursor config directory
get_cursor_config_dir() {
    local os=$1
    case "$os" in
        macos)
            echo "$HOME/Library/Application Support/Cursor/User"
            ;;
        linux)
            echo "$HOME/.config/Cursor/User"
            ;;
        windows)
            echo "$APPDATA/Cursor/User"
            ;;
        *)
            error "Unsupported OS: $os"
            return 1
            ;;
    esac
}

# Find cursor command
find_cursor_command() {
    # Check if cursor is already in PATH
    if command -v cursor &> /dev/null; then
        echo "cursor"
        return 0
    fi
    
    # OS-specific paths
    case "$(detect_os)" in
        macos)
            if [[ -x "/Applications/Cursor.app/Contents/Resources/app/bin/cursor" ]]; then
                echo "/Applications/Cursor.app/Contents/Resources/app/bin/cursor"
                return 0
            fi
            ;;
        linux)
            local linux_paths=(
                "/usr/share/cursor/bin/cursor"
                "/opt/cursor/bin/cursor"
                "$HOME/.local/share/cursor/bin/cursor"
                "/usr/local/bin/cursor"
            )
            for path in "${linux_paths[@]}"; do
                if [[ -x "$path" ]]; then
                    echo "$path"
                    return 0
                fi
            done
            ;;
        windows)
            # Windows paths (running under Git Bash or WSL)
            local win_paths=(
                "/c/Program Files/Cursor/bin/cursor"
                "/c/Users/$USER/AppData/Local/Programs/cursor/bin/cursor"
            )
            for path in "${win_paths[@]}"; do
                if [[ -x "$path" ]]; then
                    echo "$path"
                    return 0
                fi
            done
            ;;
    esac
    
    return 1
}

# Detect shell
detect_shell() {
    if [[ -n "${SHELL:-}" ]]; then
        basename "$SHELL"
    elif [[ -n "${BASH_VERSION:-}" ]]; then
        echo "bash"
    elif [[ -n "${ZSH_VERSION:-}" ]]; then
        echo "zsh"
    else
        echo "sh"
    fi
}

# Get shell config file
get_shell_config() {
    local shell=$(detect_shell)
    case "$shell" in
        zsh)
            echo "$HOME/.zshrc"
            ;;
        bash)
            if [[ -f "$HOME/.bash_profile" ]]; then
                echo "$HOME/.bash_profile"
            else
                echo "$HOME/.bashrc"
            fi
            ;;
        fish)
            echo "$HOME/.config/fish/config.fish"
            ;;
        *)
            echo "$HOME/.profile"
            ;;
    esac
}

# Backup file
backup_file() {
    local file=$1
    if [[ -f "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$file" "$backup"
        info "Backed up: $file -> $backup"
    fi
}

# Copy Cursor configs
install_cursor_configs() {
    log "Installing Cursor configurations..."
    
    local os=$(detect_os)
    local config_dir=$(get_cursor_config_dir "$os")
    
    if [[ ! -d "$config_dir" ]]; then
        warning "Cursor config directory not found: $config_dir"
        if confirm "Create directory?"; then
            mkdir -p "$config_dir"
        else
            return 1
        fi
    fi
    
    # Files to copy
    local files=("settings.json" "keybindings.json")
    
    for file in "${files[@]}"; do
        local src="$SCRIPT_DIR/cursor/$file"
        local dst="$config_dir/$file"
        
        if [[ ! -f "$src" ]]; then
            warning "Source file not found: $src"
            continue
        fi
        
        # Backup existing file
        if [[ "$BACKUP" == true ]] && [[ -f "$dst" ]]; then
            backup_file "$dst"
        fi
        
        # Copy file
        cp "$src" "$dst"
        log "Copied: $file"
    done
}

# Install extensions
install_cursor_extensions() {
    log "Installing Cursor extensions..."
    
    local script="$SCRIPT_DIR/cursor/install_extensions.sh"
    if [[ ! -f "$script" ]]; then
        error "Extension installer not found: $script"
        return 1
    fi
    
    # Make executable and run
    chmod +x "$script"
    "$script"
}

# Add cursor to PATH
setup_cursor_path() {
    log "Setting up Cursor in PATH..."
    
    local cursor_cmd=$(find_cursor_command)
    if [[ -z "$cursor_cmd" ]]; then
        warning "Cursor command not found. Please install Cursor first."
        return 1
    fi
    
    # If cursor is already in PATH, we're done
    if [[ "$cursor_cmd" == "cursor" ]]; then
        info "Cursor is already in PATH"
        return 0
    fi
    
    # Get cursor bin directory
    local cursor_bin=$(dirname "$cursor_cmd")
    local shell_config=$(get_shell_config)
    
    # Check if PATH entry already exists
    if grep -q "$cursor_bin" "$shell_config" 2>/dev/null; then
        info "PATH entry already exists in $shell_config"
        return 0
    fi
    
    # Add to shell config
    if confirm "Add Cursor to PATH in $shell_config?"; then
        echo "" >> "$shell_config"
        echo "# Added by dotfiles setup.sh" >> "$shell_config"
        echo "export PATH=\"$cursor_bin:\$PATH\"" >> "$shell_config"
        log "Added Cursor to PATH in $shell_config"
        info "Please restart your terminal or run: source $shell_config"
    fi
}

# Main setup
main() {
    echo -e "${BLUE}Dotfiles Setup Script${NC}"
    echo "====================="
    echo ""
    
    # Detect environment
    local os=$(detect_os)
    log "Detected OS: $os"
    
    if [[ "$os" == "unknown" ]]; then
        error "Unsupported operating system"
        exit 1
    fi
    
    # Check if Cursor is installed
    if ! find_cursor_command &>/dev/null; then
        error "Cursor is not installed. Please install Cursor first."
        echo "Download from: https://cursor.sh"
        exit 1
    fi
    
    # Run setup steps
    echo ""
    install_cursor_configs || warning "Failed to install some configs"
    echo ""
    install_cursor_extensions || warning "Failed to install some extensions"
    echo ""
    setup_cursor_path || warning "Failed to setup PATH"
    
    # Summary
    echo ""
    echo -e "${GREEN}Setup complete!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Restart Cursor to load the new configuration"
    echo "2. Restart your terminal to update PATH (if modified)"
    echo ""
    echo "Your Cursor is now configured with:"
    echo "  • Dark theme with custom colors"
    echo "  • Python development tools"
    echo "  • Jupyter notebook support"
    echo "  • Custom keybindings"
    echo "  • And more!"
}

# Run main
main "$@"
#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXT_FILE="${SCRIPT_DIR}/extensions.txt"

# Find cursor command
find_cursor_command() {
    # Check if cursor is already in PATH
    if command -v cursor &> /dev/null; then
        echo "cursor"
        return 0
    fi
    
    # OS-specific paths
    case "$(uname -s)" in
        Darwin)
            # macOS
            if [[ -x "/Applications/Cursor.app/Contents/Resources/app/bin/cursor" ]]; then
                echo "/Applications/Cursor.app/Contents/Resources/app/bin/cursor"
                return 0
            fi
            ;;
        Linux)
            # Common Linux paths
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
    esac
    
    return 1
}

# Main installation
main() {
    echo -e "${GREEN}Cursor Extension Installer${NC}"
    echo "================================"
    
    # Check extensions file
    if [[ ! -f "$EXT_FILE" ]]; then
        echo -e "${RED}Error: extensions.txt not found at $EXT_FILE${NC}"
        exit 1
    fi
    
    # Find cursor command
    echo -n "Finding Cursor executable... "
    if CURSOR_CMD=$(find_cursor_command); then
        echo -e "${GREEN}Found at: $CURSOR_CMD${NC}"
    else
        echo -e "${RED}Not found!${NC}"
        echo "Please ensure Cursor is installed and try again."
        echo "You can also add cursor to your PATH manually."
        exit 1
    fi
    
    # Count extensions
    total_extensions=$(grep -v '^#' "$EXT_FILE" | grep -v '^[[:space:]]*$' | wc -l | tr -d ' ')
    echo -e "Found ${GREEN}$total_extensions${NC} extensions to install"
    echo ""
    
    # Install extensions
    installed=0
    skipped=0
    failed=0
    
    while IFS= read -r extension || [[ -n "$extension" ]]; do
        # Skip comments and empty lines
        [[ "$extension" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${extension// }" ]] && continue
        
        # Trim whitespace
        extension=$(echo "$extension" | xargs)
        
        echo -n "Installing $extension... "
        
        # Check if already installed
        if "$CURSOR_CMD" --list-extensions 2>/dev/null | grep -q "^${extension}$"; then
            echo -e "${YELLOW}already installed${NC}"
            ((skipped++))
            continue
        fi
        
        # Install extension
        if output=$("$CURSOR_CMD" --install-extension "$extension" 2>&1); then
            echo -e "${GREEN}success${NC}"
            ((installed++))
        else
            # Check if it's just already installed (different message format)
            if echo "$output" | grep -q "already installed"; then
                echo -e "${YELLOW}already installed${NC}"
                ((skipped++))
            else
                echo -e "${RED}failed${NC}"
                ((failed++))
            fi
        fi
    done < "$EXT_FILE"
    
    # Summary
    echo ""
    echo "================================"
    echo -e "Installation complete!"
    echo -e "  ${GREEN}Installed: $installed${NC}"
    echo -e "  ${YELLOW}Skipped: $skipped${NC}"
    if [[ $failed -gt 0 ]]; then
        echo -e "  ${RED}Failed: $failed${NC}"
    fi
    
    # PATH suggestion
    if [[ "$CURSOR_CMD" == *"/Applications/Cursor.app"* ]] || [[ "$CURSOR_CMD" == *"/opt/"* ]]; then
        echo ""
        echo -e "${YELLOW}Tip:${NC} Add Cursor to your PATH by adding this to your shell config:"
        echo -e "  export PATH=\"$(dirname "$CURSOR_CMD"):\$PATH\""
    fi
}

main "$@"
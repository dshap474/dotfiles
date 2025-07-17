# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a dotfiles repository for managing Cursor IDE (VS Code fork) configuration and development environment settings. The repository is designed to maintain consistent development environments across multiple machines with a focus on Python development.

## Common Commands

### Git Workflow
```bash
# Push changes
git add . ; git commit -m "Your commit message" ; git push origin main

# Force pull (overwrites local changes)
git reset --hard origin/main
git pull origin main
```

### Extension Management
```bash
# Install all Cursor extensions (Unix/Mac)
cd cursor && ./install_extensions.sh

# Install all Cursor extensions (Windows)
cd cursor && .\install_extensions.ps1
```

### Generate Repository Tree
```bash
# Windows
tree /f /a > .repomix/tree.txt

# Mac/Unix
tree -afi > .repomix/tree.txt
```

## Architecture and Structure

This repository follows a simple configuration-based structure:

```
dotfiles/
├── .claude/                    # Claude AI editor permissions
│   └── settings.local.json     # Allowed bash commands (ls, iconv, find)
├── .notes/                     # Quick reference commands
│   └── __commands__.md         # Common git and tree commands
└── cursor/                     # Cursor IDE configuration
    ├── extensions.txt          # Extension list (UTF-16LE encoding)
    ├── install_extensions.sh   # Unix/Mac installer script
    ├── install_extensions.ps1  # Windows installer script
    ├── keybindings.json       # Custom keyboard shortcuts
    └── settings.json          # IDE settings and theme
```

## Key Configuration Details

### Cursor Settings
- **Theme**: Custom dark theme with charcoal colors (#1A1A1A background)
- **Python Setup**: Black formatter, Jupyter support, Python debugging
- **Remote Development**: SSH profiles configured for "seven7s" servers
- **Font**: JetBrains Mono, size 12, with ligatures enabled

### Custom Keybindings
- `Ctrl+1`: Comment/uncomment line (replaces default Ctrl+/)
- `Ctrl+I`: Open Cursor composer mode

### Extension Encoding Note
The `extensions.txt` file uses UTF-16LE encoding. When reading or modifying this file, ensure proper encoding handling:
```bash
# Convert to UTF-8 for viewing
iconv -f UTF-16LE -t UTF-8 cursor/extensions.txt
```

## Development Focus

This configuration is optimized for:
- Python development (Black formatter, Pylance, debugger)
- Jupyter notebooks
- Remote SSH development
- Git integration with conventional commit support

## Cross-Platform Support

The repository includes both Windows (PowerShell) and Unix/Mac (Bash) scripts for extension installation. The scripts automatically read from the extensions.txt file and install all listed extensions using the Cursor CLI.
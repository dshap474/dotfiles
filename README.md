# Dotfiles

Personal development environment configuration files, optimized for Cursor IDE.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/dotfiles.git
cd dotfiles

# Run the setup script
./setup.sh
```

That's it! The setup script will handle everything automatically.

## What's Included

### Cursor IDE Configuration
- **Custom Theme**: Dark theme with charcoal colors (#161616 background)
- **Python Development**: Black formatter, Pylance, debugger, and more
- **Jupyter Support**: Full notebook support with cell tags and slideshow
- **Remote Development**: SSH configuration for remote servers
- **Custom Keybindings**:
  - `Cmd+1` (Mac) / `Ctrl+1` (Win/Linux): Comment/uncomment line
  - `Cmd+I` (Mac) / `Ctrl+I` (Win/Linux): Open Cursor composer

### Extensions
The setup automatically installs:
- Python language server and tools
- Jupyter notebook support
- Remote SSH development
- Material icon theme
- CSV file highlighting

## Manual Installation

If you prefer to install components separately:

```bash
# 1. Copy Cursor configurations
cp cursor/settings.json ~/Library/Application\ Support/Cursor/User/
cp cursor/keybindings.json ~/Library/Application\ Support/Cursor/User/

# 2. Install extensions
cd cursor
./install_extensions.sh

# 3. Add Cursor to PATH (optional)
export PATH="/Applications/Cursor.app/Contents/Resources/app/bin:$PATH"
```

## Setup Options

```bash
./setup.sh --help

Options:
  --force, -f     Force installation without prompts
  --no-backup     Skip backing up existing configs
  --verbose, -v   Show detailed output
  --help, -h      Show help message
```

## Directory Structure

```
dotfiles/
├── cursor/                    # Cursor IDE configuration
│   ├── extensions.txt        # Extension list with descriptions
│   ├── install_extensions.sh # Extension installer script
│   ├── keybindings.json     # Custom keyboard shortcuts
│   └── settings.json        # IDE settings and theme
├── setup.sh                 # Master setup script
├── CLAUDE.md               # AI assistant guidance
└── README.md              # This file
```

## Platform Support

- ✅ macOS
- ✅ Linux
- ⚠️  Windows (via Git Bash or WSL)

## Troubleshooting

### Cursor command not found
The setup script will attempt to add Cursor to your PATH automatically. If it fails, add this to your shell config:

```bash
# macOS
export PATH="/Applications/Cursor.app/Contents/Resources/app/bin:$PATH"

# Linux (adjust path as needed)
export PATH="/opt/cursor/bin:$PATH"
```

### Extensions fail to install
Make sure Cursor is installed and accessible. The installer will try multiple common paths, but you can also specify the path manually.

### Settings not applied
Restart Cursor after running the setup script for all changes to take effect.

## Customization

Feel free to modify the configuration files to suit your preferences:
- `cursor/settings.json`: IDE settings and theme colors
- `cursor/keybindings.json`: Keyboard shortcuts
- `cursor/extensions.txt`: List of extensions to install

## Contributing

Pull requests are welcome! Please ensure any changes work across macOS and Linux.
# Dotfiles

Personal settings I save here so they are easy to restore on a new computer.

## Layout

```text
dotfiles/
├── claude-code/   # ~/.claude settings, agents, and CLAUDE.md
├── codex/         # ~/.codex config, AGENTS.md, and agents
├── cursor/        # Cursor settings, keybindings, extensions, installers
├── ghostty/       # ~/.config/ghostty config and themes
├── zed/           # ~/.config/zed settings and keymap
├── setup.sh       # Existing setup helper
└── README.md
```

## Restore

Copy the folder contents back to their app-specific locations:

```bash
cp cursor/settings.json ~/Library/Application\ Support/Cursor/User/
cp cursor/keybindings.json ~/Library/Application\ Support/Cursor/User/
cp ghostty/config.ghostty ~/.config/ghostty/config.ghostty
cp ghostty/themes/* ~/.config/ghostty/themes/
cp zed/settings.json ~/.config/zed/settings.json
cp zed/keymap.json ~/.config/zed/keymap.json
cp codex/config.toml ~/.codex/config.toml
cp codex/AGENTS.md ~/.codex/AGENTS.md
cp -R codex/agents ~/.codex/
cp claude-code/settings.json ~/.claude/settings.json
cp claude-code/CLAUDE.md ~/.claude/CLAUDE.md
cp -R claude-code/agents ~/.claude/
```

## Cursor Extensions

```bash
cd cursor
./install_extensions.sh
```
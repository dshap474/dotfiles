# Ghostty Terminal - Cursor Dark Theme Setup

This guide helps you set up the Cursor Dark theme for Ghostty terminal to match your Cursor IDE.

## Installation

### 1. Create the themes folder
```bash
mkdir -p ~/.config/ghostty/themes
```

### 2. Create the theme file
```bash
nano ~/.config/ghostty/themes/cursor-dark
```

### 3. Add the theme content
Paste this exact content (no comments, 6-digit hex only):

```
background = #151515
foreground = #d8dee9
cursor-color = #ffffff
selection-background = #636262

palette = 0=#2a2a2a
palette = 1=#bf616a
palette = 2=#a3be8c
palette = 3=#ebcb8b
palette = 4=#81a1c1
palette = 5=#b48ead
palette = 6=#88c0d0
palette = 7=#ffffff
palette = 8=#505050
palette = 9=#bf616a
palette = 10=#a3be8c
palette = 11=#ebcb8b
palette = 12=#81a1c1
palette = 13=#b48ead
palette = 14=#88c0d0
palette = 15=#ffffff
```

### 4. Configure Ghostty to use the theme
Edit your main config:
```bash
nano ~/Library/Application\ Support/com.mitchellh.ghostty/config
```

Add or set:
```
theme = "cursor-dark"
```

### 5. Restart Ghostty
Fully quit and reopen Ghostty for the theme to take effect.

## Verify Colors

Run this command to test the color palette:
```bash
printf "\033[31mRed \033[32mGreen \033[34mBlue \033[0m\n"
```

You should see red/green/blue text that matches the palette colors.

## Troubleshooting

- **"theme not found"** → File must be `~/.config/ghostty/themes/cursor-dark` (no extension)
- **Unknown field / invalid value** →
  - Use keys: `background`, `foreground`, `cursor-color`, `selection-background`, `palette`
  - Palette format: `palette = N=#RRGGBB` (not `colorN`)
  - No alpha hex (e.g., avoid `#ffffffcc`), and no inline comments on value lines
- **Theme didn't apply** → Fully quit and relaunch Ghostty; some versions don't hot-reload

## Theme File

For convenience, the theme file is also included in this repository:
- `ghostty/themes/cursor-dark` - Copy this to `~/.config/ghostty/themes/`
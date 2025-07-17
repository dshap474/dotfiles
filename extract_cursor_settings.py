#!/usr/bin/env python3
"""
Extract Cursor Settings
---
Extract and sync Cursor IDE settings to dotfiles repository
"""

import os
import sys
import platform
import shutil
import subprocess
import json
from pathlib import Path
from datetime import datetime
from typing import Optional, List, Tuple

# ┌────────────────────────────────────────────────────────────────────────────────────┐
# │ Configuration                                                                      │
# └────────────────────────────────────────────────────────────────────────────────────┘

CURSOR_SETTINGS_FILES = ["settings.json", "keybindings.json"]
EXTENSIONS_FILE = "extensions.txt"
BACKUP_SUFFIX = ".backup"


# ┌────────────────────────────────────────────────────────────────────────────────────┐
# │ Platform Detection                                                                 │
# └────────────────────────────────────────────────────────────────────────────────────┘

def get_cursor_user_path() -> Path:
    """Get the Cursor user settings directory based on the operating system."""
    system = platform.system()
    
    if system == "Darwin":  # macOS
        return Path.home() / "Library" / "Application Support" / "Cursor" / "User"
    elif system == "Windows":
        appdata = os.environ.get("APPDATA")
        if not appdata:
            raise RuntimeError("APPDATA environment variable not found")
        return Path(appdata) / "Cursor" / "User"
    elif system == "Linux":
        return Path.home() / ".config" / "Cursor" / "User"
    else:
        raise RuntimeError(f"Unsupported operating system: {system}")


# ┌────────────────────────────────────────────────────────────────────────────────────┐
# │ File Operations                                                                    │
# └────────────────────────────────────────────────────────────────────────────────────┘

def backup_file(file_path: Path) -> Optional[Path]:
    """Create a backup of the file if it exists."""
    if file_path.exists():
        backup_path = file_path.with_suffix(file_path.suffix + BACKUP_SUFFIX)
        shutil.copy2(file_path, backup_path)
        return backup_path
    return None


def copy_settings_file(source_path: Path, dest_path: Path, file_name: str) -> bool:
    """Copy a settings file from source to destination with backup."""
    source_file = source_path / file_name
    dest_file = dest_path / file_name
    
    if not source_file.exists():
        print(f"⚠️  Source file not found: {source_file}")
        return False
    
    # Create backup if destination exists
    backup_path = backup_file(dest_file)
    if backup_path:
        print(f"📦 Backed up: {file_name} → {backup_path.name}")
    
    # Copy the file
    shutil.copy2(source_file, dest_file)
    print(f"✅ Copied: {file_name}")
    return True


# ┌────────────────────────────────────────────────────────────────────────────────────┐
# │ Extensions Management                                                              │
# └────────────────────────────────────────────────────────────────────────────────────┘

def get_installed_extensions() -> List[str]:
    """Get list of installed Cursor extensions."""
    try:
        result = subprocess.run(
            ["cursor", "--list-extensions"],
            capture_output=True,
            text=True,
            check=True
        )
        extensions = result.stdout.strip().split('\n')
        return [ext for ext in extensions if ext]  # Filter empty lines
    except subprocess.CalledProcessError as e:
        print(f"❌ Error getting extensions: {e}")
        return []
    except FileNotFoundError:
        print("❌ Cursor CLI not found. Make sure Cursor is installed and in PATH.")
        return []


def write_extensions_file(extensions: List[str], dest_path: Path) -> bool:
    """Write extensions list to file in UTF-16LE encoding."""
    extensions_file = dest_path / EXTENSIONS_FILE
    
    # Create backup if file exists
    backup_path = backup_file(extensions_file)
    if backup_path:
        print(f"📦 Backed up: {EXTENSIONS_FILE} → {backup_path.name}")
    
    try:
        # Write with UTF-16LE encoding to match existing format
        with open(extensions_file, 'w', encoding='utf-16le') as f:
            f.write('\n'.join(extensions))
        print(f"✅ Updated: {EXTENSIONS_FILE} ({len(extensions)} extensions)")
        return True
    except Exception as e:
        print(f"❌ Error writing extensions file: {e}")
        return False


# ┌────────────────────────────────────────────────────────────────────────────────────┐
# │ Git Operations                                                                     │
# └────────────────────────────────────────────────────────────────────────────────────┘

def git_add_commit_push(repo_path: Path, message: str) -> bool:
    """Add, commit, and push changes to git repository."""
    try:
        # Change to repo directory
        original_cwd = os.getcwd()
        os.chdir(repo_path)
        
        # Git add
        subprocess.run(["git", "add", "."], check=True)
        
        # Git commit
        subprocess.run(["git", "commit", "-m", message], check=True)
        
        # Git push
        subprocess.run(["git", "push", "origin", "main"], check=True)
        
        print(f"\n✅ Changes committed and pushed: {message}")
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"\n⚠️  Git operation failed: {e}")
        return False
    finally:
        os.chdir(original_cwd)


# ┌────────────────────────────────────────────────────────────────────────────────────┐
# │ Main Extraction Logic                                                              │
# └────────────────────────────────────────────────────────────────────────────────────┘

def extract_cursor_settings(auto_commit: bool = True) -> None:
    """Main function to extract and sync Cursor settings."""
    print("🚀 Cursor Settings Extractor")
    print("=" * 40)
    
    # Get paths
    script_dir = Path(__file__).parent
    cursor_dir = script_dir / "cursor"
    
    # Ensure cursor directory exists
    cursor_dir.mkdir(exist_ok=True)
    
    # Get Cursor user path
    try:
        cursor_user_path = get_cursor_user_path()
        print(f"📍 Cursor user path: {cursor_user_path}")
    except RuntimeError as e:
        print(f"❌ {e}")
        sys.exit(1)
    
    if not cursor_user_path.exists():
        print(f"❌ Cursor user directory not found: {cursor_user_path}")
        sys.exit(1)
    
    print(f"📍 Destination: {cursor_dir}")
    print()
    
    # Track what was updated
    updated_files = []
    
    # Copy settings files
    print("📋 Copying configuration files...")
    for file_name in CURSOR_SETTINGS_FILES:
        if copy_settings_file(cursor_user_path, cursor_dir, file_name):
            updated_files.append(file_name)
    
    # Extract and save extensions
    print("\n🧩 Extracting installed extensions...")
    extensions = get_installed_extensions()
    if extensions:
        if write_extensions_file(extensions, cursor_dir):
            updated_files.append(EXTENSIONS_FILE)
    
    # Summary
    print("\n" + "=" * 40)
    if updated_files:
        print(f"✅ Successfully updated {len(updated_files)} files:")
        for file in updated_files:
            print(f"   - {file}")
        
        # Git operations
        if auto_commit:
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            commit_message = f"Update Cursor settings - {timestamp}"
            print(f"\n🔄 Committing changes...")
            git_add_commit_push(script_dir, commit_message)
    else:
        print("⚠️  No files were updated")
    
    print("\n✨ Done!")


# ┌────────────────────────────────────────────────────────────────────────────────────┐
# │ Entry Point                                                                        │
# └────────────────────────────────────────────────────────────────────────────────────┘

if __name__ == "__main__":
    # Check for --no-commit flag
    auto_commit = "--no-commit" not in sys.argv
    
    if not auto_commit:
        print("ℹ️  Running without auto-commit")
    
    extract_cursor_settings(auto_commit)
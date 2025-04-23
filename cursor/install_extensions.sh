#!/bin/bash
set -euo pipefail

EXT_FILE="$(dirname "$0")/extensions.txt"
if [[ ! -f "$EXT_FILE" ]]; then
  echo "Error: $EXT_FILE not found."
  exit 1
fi

echo "Installing Cursor extensions from $EXT_FILE..."
cat "$EXT_FILE" | xargs -n1 cursor --install-extension 
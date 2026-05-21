#!/usr/bin/env bash
# Symlink wrap-claude into ~/.local/bin so it's on PATH.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="$HOME/.local/bin/wrap-claude"

mkdir -p "$HOME/.local/bin"

if [[ -L "$TARGET" || -e "$TARGET" ]]; then
  echo "install: $TARGET already exists — removing"
  rm -f "$TARGET"
fi

ln -s "$REPO_DIR/wrap-claude" "$TARGET"
chmod +x "$REPO_DIR/wrap-claude"

echo "install: $TARGET -> $REPO_DIR/wrap-claude"

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) echo "install: WARNING — \$HOME/.local/bin is not on PATH" >&2 ;;
esac

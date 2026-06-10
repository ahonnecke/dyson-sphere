#!/usr/bin/env bash
# Symlink wrap-claude into ~/.local/bin so it's on PATH.
set -euo pipefail

# RETIRED 2026-06-10 — see README. wrap-claude duplicated Claude Code's native
# bubblewrap sandbox and was weaker than dev-cradle for untrusted work. Don't
# resurrect it on PATH by accident; pass DYSON_SPHERE_FORCE_INSTALL=1 to override.
if [[ "${DYSON_SPHERE_FORCE_INSTALL:-}" != "1" ]]; then
  echo "dyson-sphere is retired — wrap-claude is no longer installed." >&2
  echo "Trusted work: plain claude/ct. Untrusted: \`ct cradle\`." >&2
  echo "To install anyway: DYSON_SPHERE_FORCE_INSTALL=1 $0" >&2
  exit 1
fi

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
